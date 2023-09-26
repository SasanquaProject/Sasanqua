module main
    # (
        parameter START_ADDR = 32'h2000_0000
    )
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,

        /* ----- MMU接続 ----- */
        // 命令
        output wire         INST_RDEN,
        output wire [31:0]  INST_RIADDR,
        input wire  [31:0]  INST_ROADDR,
        input wire          INST_RVALID,
        input wire  [31:0]  INST_RDATA,

        // データ
        output wire         DATA_RDEN,
        output wire [31:0]  DATA_RIADDR,
        input wire  [31:0]  DATA_ROADDR,
        input wire          DATA_RVALID,
        input wire  [31:0]  DATA_RDATA,
        output wire         DATA_WREN,
        output wire [31:0]  DATA_WADDR,
        output wire [31:0]  DATA_WDATA,

        // ハザード
        input wire          MEM_WAIT,

        /* ----- 割り込み ----- */
        input wire          INT_EN,
        input wire  [3:0]   INT_CODE
    );

    /* ----- パイプライン制御 ----- */
    // 制御信号
    wire        flush    = trap_en || memr_jmp_do;
    wire [31:0] flush_pc = trap_en ? trap_jmp_to : memr_jmp_pc;
    wire        stall    = !reg_rs1_valid || !reg_rs2_valid || !reg_csr_valid;

    // PC管理
    reg  [31:0] executing_pc;

    /* ----- 1. 命令フェッチ ----- */
    wire [31:0] inst_pc, inst_data;

    fetch # (
        .START_ADDR (START_ADDR)
    ) fetch (
        // 制御
        .CLK        (CLK),
        .RST        (RST),
        .FLUSH      (flush),
        .FLUSH_PC   (flush_pc),
        .STALL      (stall),
        .MEM_WAIT   (MEM_WAIT),

        // MMUとの接続
        .INST_RDEN  (INST_RDEN),
        .INST_RIADDR(INST_RIADDR),
        .INST_RVALID(INST_RVALID),
        .INST_ROADDR(INST_ROADDR),
        .INST_RDATA (INST_RDATA),

        // 後段との接続
        .INST_PC    (inst_pc),
        .INST_DATA  (inst_data)
    );

    /* ----- 2. 命令デコード ----- */
    wire [31:0] decode_pc, decode_imm;
    wire [16:0] decode_opcode;
    wire [4:0]  decode_rd, decode_rs1, decode_rs2;

    decode decode (
        // 制御
        .CLK            (CLK),
        .RST            (RST),
        .FLUSH          (flush),
        .STALL          (stall),
        .MEM_WAIT       (MEM_WAIT),

        // フェッチ部との接続
        .INST_PC        (inst_pc),
        .INST_DATA      (inst_data),

        // 検査部との接続
        .DECODE_PC      (decode_pc),
        .DECODE_OPCODE  (decode_opcode),
        .DECODE_RD      (decode_rd),
        .DECODE_RS1     (decode_rs1),
        .DECODE_RS2     (decode_rs2),
        .DECODE_IMM     (decode_imm)
    );

    /* ----- 3. 命令検査 ----- */
    wire [31:0] check_pc, check_imm;
    wire [11:0] check_csr;
    wire [16:0] check_opcode;
    wire [4:0]  check_rd, check_rs1, check_rs2;

    check check (
        // 制御
        .CLK            (CLK),
        .RST            (RST),
        .FLUSH          (flush),
        .STALL          (stall),
        .MEM_WAIT       (MEM_WAIT),

        // デコード部1との接続
        .DECODE_PC      (decode_pc),
        .DECODE_OPCODE  (decode_opcode),
        .DECODE_RD      (decode_rd),
        .DECODE_RS1     (decode_rs1),
        .DECODE_RS2     (decode_rs2),
        .DECODE_IMM     (decode_imm),

        // スケジューラ1との接続
        .CHECK_PC       (check_pc),
        .CHECK_OPCODE   (check_opcode),
        .CHECK_RD       (check_rd),
        .CHECK_RS1      (check_rs1),
        .CHECK_RS2      (check_rs2),
        .CHECK_CSR      (check_csr),
        .CHECK_IMM      (check_imm)
    );

    /* ----- 4-1. スケジューリング1 ----- */
    wire [31:0] schedule_pc, schedule_imm;
    wire [11:0] schedule_csr;
    wire [16:0] schedule_opcode;
    wire [4:0]  schedule_rd, schedule_rs1, schedule_rs2;

    schedule schedule (
        // 制御
        .CLK                (CLK),
        .RST                (RST),
        .FLUSH              (flush),
        .STALL              (stall),
        .MEM_WAIT           (MEM_WAIT),

        // デコード部2との接続
        .CHECK_PC           (check_pc),
        .CHECK_OPCODE       (check_opcode),
        .CHECK_RD           (check_rd),
        .CHECK_CSR          (check_csr),
        .CHECK_IMM          (check_imm),

        // 実行部との接続
        .SCHEDULE_PC        (schedule_pc),
        .SCHEDULE_OPCODE    (schedule_opcode),
        .SCHEDULE_RD        (schedule_rd),
        .SCHEDULE_CSR       (schedule_csr),
        .SCHEDULE_IMM       (schedule_imm)
    );

    /* ----- 4-2. レジスタアクセス ----- */
    // CSR
    wire [1:0]  trap_vec_mode;
    wire [31:0] trap_vec_base;
    wire        int_allow;

    wire [31:0] reg_csr_data;
    wire [11:0] reg_csr_addr;
    wire        reg_csr_valid;

    reg_std_csr reg_std_csr_0 (
        // 制御
        .CLK                (CLK),
        .RST                (RST),
        .FLUSH              (flush),
        .STALL              (stall),
        .MEM_WAIT           (MEM_WAIT),
        .TRAP_EN            (trap_en),
        .TRAP_CODE          (trap_code),
        .TRAP_PC            (trap_pc),
        .TRAP_VEC_MODE      (trap_vec_mode),
        .TRAP_VEC_BASE      (trap_vec_base),
        .INT_ALLOW          (int_allow),

        // レジスタアクセス
        .RIADDR             (check_csr),
        .RVALID             (reg_csr_valid),
        .ROADDR             (reg_csr_addr),
        .RDATA              (reg_csr_data),
        .WREN               (memr_csr_w_en),
        .WADDR              (memr_csr_w_addr),
        .WDATA              (memr_csr_w_data),

        // フォワーディング
        .FWD_CSR_ADDR       (schedule_csr),
        .FWD_EXEC_EN        (exec_csr_w_en),
        .FWD_EXEC_ADDR      (exec_csr_w_addr),
        .FWD_EXEC_DATA      (exec_csr_w_data),
        .FWD_CUSHION_EN     (cushion_csr_w_en),
        .FWD_CUSHION_ADDR   (cushion_csr_w_addr),
        .FWD_CUSHION_DATA   (cushion_csr_w_data)
    );

    // RV32I
    wire [31:0] reg_rs1_data, reg_rs2_data;
    wire [4:0]  reg_rs1_addr, reg_rs2_addr;
    wire        reg_rs1_valid, reg_rs2_valid;

    reg_std_rv32i reg_std_rv32i_0 (
        // 制御
        .CLK                (CLK),
        .RST                (RST),
        .FLUSH              (flush),
        .STALL              (stall),
        .MEM_WAIT           (MEM_WAIT),

        // レジスタアクセス
        .A_RIADDR           (check_rs1),
        .A_RVALID           (reg_rs1_valid),
        .A_ROADDR           (reg_rs1_addr),
        .A_RDATA            (reg_rs1_data),
        .B_RIADDR           (check_rs2),
        .B_RVALID           (reg_rs2_valid),
        .B_ROADDR           (reg_rs2_addr),
        .B_RDATA            (reg_rs2_data),
        .WADDR              (memr_reg_w_rd),
        .WDATA              (memr_reg_w_data),

        // フォワーディング
        .FWD_REG_ADDR       (schedule_rd),
        .FWD_EXEC_EN        (exec_reg_w_en),
        .FWD_EXEC_ADDR      (exec_reg_w_rd),
        .FWD_EXEC_DATA      (exec_reg_w_data),
        .FWD_CUSHION_EN     (cushion_reg_w_en),
        .FWD_CUSHION_ADDR   (cushion_reg_w_rd),
        .FWD_CUSHION_DATA   (cushion_reg_w_data)
    );

    /* ----- 5. 実行 ----- */
    wire        exec_reg_w_en, exec_mem_r_en, exec_mem_r_signed, exec_csr_w_en, exec_mem_w_en, exec_jmp_do, exec_exc_en;
    wire [31:0] exec_pc, exec_reg_w_data, exec_csr_w_data, exec_mem_r_addr, exec_mem_w_addr, exec_mem_w_data, exec_jmp_pc;
    wire [11:0] exec_csr_w_addr;
    wire [4:0]  exec_reg_w_rd, exec_mem_r_rd;
    wire [3:0]  exec_mem_r_strb, exec_mem_w_strb, exec_exc_code;

    exec_std_rv32i_s exec_std_rv32i_s_0 (
        // 制御
        .CLK                (CLK),
        .RST                (RST),
        .FLUSH              (flush),
        .STALL              (stall),
        .MEM_WAIT           (MEM_WAIT),

        // 前段との接続
        .PC                 (schedule_pc),
        .OPCODE             (schedule_opcode),
        .RD_ADDR            (schedule_rd),
        .RS1_ADDR           (reg_rs1_addr),
        .RS1_DATA           (reg_rs1_data),
        .RS2_ADDR           (reg_rs2_addr),
        .RS2_DATA           (reg_rs2_data),
        .CSR_ADDR           (reg_csr_addr),
        .CSR_DATA           (reg_csr_data),
        .IMM                (schedule_imm),

        // 後段との接続
        .EXEC_PC            (exec_pc),
        .EXEC_REG_W_EN      (exec_reg_w_en),
        .EXEC_REG_W_RD      (exec_reg_w_rd),
        .EXEC_REG_W_DATA    (exec_reg_w_data),
        .EXEC_CSR_W_EN      (exec_csr_w_en),
        .EXEC_CSR_W_ADDR    (exec_csr_w_addr),
        .EXEC_CSR_W_DATA    (exec_csr_w_data),
        .EXEC_MEM_R_EN      (exec_mem_r_en),
        .EXEC_MEM_R_RD      (exec_mem_r_rd),
        .EXEC_MEM_R_ADDR    (exec_mem_r_addr),
        .EXEC_MEM_R_STRB    (exec_mem_r_strb),
        .EXEC_MEM_R_SIGNED  (exec_mem_r_signed),
        .EXEC_MEM_W_EN      (exec_mem_w_en),
        .EXEC_MEM_W_ADDR    (exec_mem_w_addr),
        .EXEC_MEM_W_STRB    (exec_mem_w_strb),
        .EXEC_MEM_W_DATA    (exec_mem_w_data),
        .EXEC_JMP_DO        (exec_jmp_do),
        .EXEC_JMP_PC        (exec_jmp_pc),
        .EXEC_EXC_EN        (exec_exc_en),
        .EXEC_EXC_CODE      (exec_exc_code)
    );

    /* ----- 6. 実行部待機 ------ */
    wire        cushion_reg_w_en, cushion_mem_r_en, cushion_mem_r_signed, cushion_csr_w_en, cushion_mem_w_en, cushion_jmp_do, cushion_exc_en;
    wire [31:0] cushion_pc, cushion_reg_w_data, cushion_csr_w_data, cushion_mem_r_addr, cushion_mem_w_addr, cushion_mem_w_data, cushion_jmp_pc;
    wire [11:0] cushion_csr_w_addr;
    wire [4:0]  cushion_reg_w_rd, cushion_mem_r_rd;
    wire [3:0]  cushion_mem_r_strb, cushion_mem_w_strb, cushion_exc_code;

    cushion cushion (
        // 制御
        .CLK                    (CLK),
        .RST                    (RST),
        .FLUSH                  (flush),
        .MEM_WAIT               (MEM_WAIT),

        // 実行部との接続
        .EXEC_PC                (exec_pc),
        .EXEC_REG_W_EN          (exec_reg_w_en),
        .EXEC_REG_W_RD          (exec_reg_w_rd),
        .EXEC_REG_W_DATA        (exec_reg_w_data),
        .EXEC_CSR_W_EN          (exec_csr_w_en),
        .EXEC_CSR_W_ADDR        (exec_csr_w_addr),
        .EXEC_CSR_W_DATA        (exec_csr_w_data),
        .EXEC_MEM_R_EN          (exec_mem_r_en),
        .EXEC_MEM_R_RD          (exec_mem_r_rd),
        .EXEC_MEM_R_ADDR        (exec_mem_r_addr),
        .EXEC_MEM_R_STRB        (exec_mem_r_strb),
        .EXEC_MEM_R_SIGNED      (exec_mem_r_signed),
        .EXEC_MEM_W_EN          (exec_mem_w_en),
        .EXEC_MEM_W_ADDR        (exec_mem_w_addr),
        .EXEC_MEM_W_STRB        (exec_mem_w_strb),
        .EXEC_MEM_W_DATA        (exec_mem_w_data),
        .EXEC_JMP_DO            (exec_jmp_do),
        .EXEC_JMP_PC            (exec_jmp_pc),
        .EXEC_EXC_EN            (exec_exc_en),
        .EXEC_EXC_CODE          (exec_exc_code),

        // メモリアクセス部(r)との接続
        .CUSHION_PC             (cushion_pc),
        .CUSHION_REG_W_EN       (cushion_reg_w_en),
        .CUSHION_REG_W_RD       (cushion_reg_w_rd),
        .CUSHION_REG_W_DATA     (cushion_reg_w_data),
        .CUSHION_CSR_W_EN       (cushion_csr_w_en),
        .CUSHION_CSR_W_ADDR     (cushion_csr_w_addr),
        .CUSHION_CSR_W_DATA     (cushion_csr_w_data),
        .CUSHION_MEM_R_EN       (cushion_mem_r_en),
        .CUSHION_MEM_R_RD       (cushion_mem_r_rd),
        .CUSHION_MEM_R_ADDR     (cushion_mem_r_addr),
        .CUSHION_MEM_R_STRB     (cushion_mem_r_strb),
        .CUSHION_MEM_R_SIGNED   (cushion_mem_r_signed),
        .CUSHION_MEM_W_EN       (cushion_mem_w_en),
        .CUSHION_MEM_W_ADDR     (cushion_mem_w_addr),
        .CUSHION_MEM_W_STRB     (cushion_mem_w_strb),
        .CUSHION_MEM_W_DATA     (cushion_mem_w_data),
        .CUSHION_JMP_DO         (cushion_jmp_do),
        .CUSHION_JMP_PC         (cushion_jmp_pc),
        .CUSHION_EXC_EN         (cushion_exc_en),
        .CUSHION_EXC_CODE       (cushion_exc_code)
    );

    /* ----- 7-1. メモリアクセス(r) ----- */
    wire        memr_csr_w_en, memr_mem_w_en, memr_jmp_do;
    wire [31:0] memr_reg_w_data, memr_csr_w_data, memr_mem_w_addr, memr_mem_w_data, memr_jmp_pc;
    wire [11:0] memr_csr_w_addr;
    wire [4:0]  memr_reg_w_rd;

    mread mread (
        // 制御
        .CLK                    (CLK),
        .RST                    (RST),
        .FLUSH                  (flush),
        .MEM_WAIT               (MEM_WAIT),

        // MMUとの接続
        .DATA_RDEN              (DATA_RDEN),
        .DATA_RIADDR            (DATA_RIADDR),
        .DATA_ROADDR            (DATA_ROADDR),
        .DATA_RVALID            (DATA_RVALID),
        .DATA_RDATA             (DATA_RDATA),

        // 実行待機部との接続
        .CUSHION_REG_W_RD       (cushion_reg_w_rd),
        .CUSHION_REG_W_DATA     (cushion_reg_w_data),
        .CUSHION_CSR_W_EN       (cushion_csr_w_en),
        .CUSHION_CSR_W_ADDR     (cushion_csr_w_addr),
        .CUSHION_CSR_W_DATA     (cushion_csr_w_data),
        .CUSHION_MEM_R_EN       (cushion_mem_r_en),
        .CUSHION_MEM_R_RD       (cushion_mem_r_rd),
        .CUSHION_MEM_R_ADDR     (cushion_mem_r_addr),
        .CUSHION_MEM_R_STRB     (cushion_mem_r_strb),
        .CUSHION_MEM_R_SIGNED   (cushion_mem_r_signed),
        .CUSHION_MEM_W_EN       (cushion_mem_w_en),
        .CUSHION_MEM_W_ADDR     (cushion_mem_w_addr),
        .CUSHION_MEM_W_STRB     (cushion_mem_w_strb),
        .CUSHION_MEM_W_DATA     (cushion_mem_w_data),
        .CUSHION_JMP_DO         (cushion_jmp_do),
        .CUSHION_JMP_PC         (cushion_jmp_pc),

        // メモリアクセス(w)との接続
        .MEMR_REG_W_RD          (memr_reg_w_rd),
        .MEMR_REG_W_DATA        (memr_reg_w_data),
        .MEMR_CSR_W_EN          (memr_csr_w_en),
        .MEMR_CSR_W_ADDR        (memr_csr_w_addr),
        .MEMR_CSR_W_DATA        (memr_csr_w_data),
        .MEMR_MEM_W_EN          (memr_mem_w_en),
        .MEMR_MEM_W_ADDR        (memr_mem_w_addr),
        .MEMR_MEM_W_DATA        (memr_mem_w_data),
        .MEMR_JMP_DO            (memr_jmp_do),
        .MEMR_JMP_PC            (memr_jmp_pc)
    );

    /* ----- 7-2. Trap処理 ----- */
    wire        trap_en;
    wire [31:0] trap_pc, trap_code, trap_jmp_to;

    trap trap (
        // 制御
        .CLK                (CLK),
        .RST                (RST),
        .FLUSH              (flush),
        .MEM_WAIT           (MEM_WAIT),

        // 前段との接続
        .INST_PC            (inst_pc),
        .DECODE_PC          (decode_pc),
        .CHECK_PC           (check_pc),
        .SCHEDULE_PC        (schedule_pc),
        .EXEC_PC            (o_pc),
        .CUSHION_PC         (cushion_pc),
        .CUSHION_EXC_EN     (cushion_exc_en),
        .CUSHION_EXC_CODE   (cushion_exc_code),

        // 割り込み
        .INT_ALLOW          (int_allow),
        .INT_EN             (INT_EN),
        .INT_CODE           (INT_CODE),

        // Trap情報
        .TRAP_VEC_MODE      (trap_vec_mode),
        .TRAP_VEC_BASE      (trap_vec_base),
        .TRAP_PC            (trap_pc),
        .TRAP_EN            (trap_en),
        .TRAP_CODE          (trap_code),
        .TRAP_JMP_TO        (trap_jmp_to)
    );

    /* ----- 8. メモリアクセス(w) ----- */
    assign DATA_WREN  = flush ? 1'b0 : memr_mem_w_en;
    assign DATA_WADDR = flush ? 32'b0 : memr_mem_w_addr;
    assign DATA_WDATA = flush ? 32'b0 : memr_mem_w_data;

endmodule

module main
    # (
        parameter START_ADDR = 32'h0
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
        output wire [3:0]   DATA_WSTRB,
        output wire [31:0]  DATA_WADDR,
        output wire [31:0]  DATA_WDATA,

        // ハザード
        input wire          MEM_WAIT,

        /* ----- 割り込み ----- */
        input wire          INT_EN,
        input wire  [3:0]   INT_CODE
    );

    /* ----- パイプライン制御 ----- */
    wire        flush    = trap_en || memr_jmp_do;
    wire [31:0] flush_pc = trap_en ? trap_jmp_to : memr_jmp_pc;
    wire        stall    = !schedule_a_rs1_valid || !schedule_a_rs2_valid || !schedule_a_csr_valid;

    /* ----- 1. 命令フェッチ ----- */
    wire [31:0] fetch_pc, fetch_inst;

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
        .FETCH_PC   (fetch_pc),
        .FETCH_INST (fetch_inst)
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

        // 前段との接続
        .PC             (fetch_pc),
        .INST           (fetch_inst),

        // 後段との接続
        .DECODE_PC      (decode_pc),
        .DECODE_OPCODE  (decode_opcode),
        .DECODE_RD      (decode_rd),
        .DECODE_RS1     (decode_rs1),
        .DECODE_RS2     (decode_rs2),
        .DECODE_IMM     (decode_imm)
    );

    /* ----- 3. 命令プール ----- */
    wire [31:0] pool_pc, pool_imm;
    wire [11:0] pool_csr;
    wire [16:0] pool_opcode;
    wire [4:0]  pool_rd, pool_rs1, pool_rs2;

    pool pool (
        // 制御
        .CLK            (CLK),
        .RST            (RST),
        .FLUSH          (flush),
        .STALL          (stall),
        .MEM_WAIT       (MEM_WAIT),

        // 前段との接続
        .PC             (decode_pc),
        .OPCODE         (decode_opcode),
        .RD             (decode_rd),
        .RS1            (decode_rs1),
        .RS2            (decode_rs2),
        .IMM            (decode_imm),

        // 後段との接続
        .POOL_PC        (pool_pc),
        .POOL_OPCODE    (pool_opcode),
        .POOL_RD        (pool_rd),
        .POOL_RS1       (pool_rs1),
        .POOL_RS2       (pool_rs2),
        .POOL_CSR       (pool_csr),
        .POOL_IMM       (pool_imm)
    );

    /* ----- 3-1. 命令検査 ----- */
    wire        check_accept;
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

        // 前段との接続
        .PC             (pool_pc),
        .OPCODE         (pool_opcode),
        .RD             (pool_rd),
        .RS1            (pool_rs1),
        .RS2            (pool_rs2),
        .IMM            (pool_imm),

        // 後段との接続
        .CHECK_ACCEPT   (check_accept),
        .CHECK_PC       (check_pc),
        .CHECK_OPCODE   (check_opcode),
        .CHECK_RD       (check_rd),
        .CHECK_RS1      (check_rs1),
        .CHECK_RS2      (check_rs2),
        .CHECK_CSR      (check_csr),
        .CHECK_IMM      (check_imm)
    );

    /* ----- 3-2. コプロセッサ ----- */
    wire        cop_accept;
    wire [31:0] cop_pc;
    wire [4:0]  cop_rd, cop_rs1, cop_rs2;

    sasanqua_cop sasanqua_cop (
        // 制御
        .CLK                (CLK),
        .RST                (RST),

        // Check 接続
        .PC                 (pool_pc),
        .OPCODE             (pool_opcode),
        .RD                 (pool_rd),
        .RS1                (pool_rs1),
        .RS2                (pool_rs2),
        .IMM                (pool_imm),
        .COP_C_ACCEPT       (cop_accept),
        .COP_C_PC           (cop_pc),
        .COP_C_RD           (cop_rd),
        .COP_C_RS1          (cop_rs1),
        .COP_C_RS2          (cop_rs2),

        // Exec 接続
        .ALLOW              (schedule_b_allow)
        // .RS1_DATA           (),
        // .RS2_DATA           (),
        // .COP_E_PC           (),
        // .COP_E_REG_W_EN     (),
        // .COP_E_REG_W_RD     (),
        // .COP_E_REG_W_DATA   (),
        // .COP_E_MEM_R_EN     (),
        // .COP_E_MEM_R_RD     (),
        // .COP_E_MEM_R_ADDR   (),
        // .COP_E_MEM_R_STRB   (),
        // .COP_E_MEM_R_SIGNED (),
        // .COP_E_MEM_W_EN     (),
        // .COP_E_MEM_W_ADDR   (),
        // .COP_E_MEM_W_STRB   (),
        // .COP_E_MEM_W_DATA   (),
        // .COP_E_EXC_EN       (),
        // .COP_E_EXC_CODE     ()
    );

    /* ----- 4-1. スケジューリング ----- */
    wire        schedule_a_allow, schedule_b_allow;
    wire [31:0] schedule_a_pc, schedule_a_imm;
    wire [11:0] schedule_a_csr;
    wire [16:0] schedule_a_opcode;
    wire [4:0]  schedule_a_rd, schedule_a_rs1, schedule_a_rs2;

    schedule schedule (
        // 制御
        .CLK                (CLK),
        .RST                (RST),
        .FLUSH              (flush),
        .STALL              (stall),
        .MEM_WAIT           (MEM_WAIT),

        // 前段との接続
        .A_ACCEPT           (check_accept),
        .A_PC               (check_pc),
        .A_OPCODE           (check_opcode),
        .A_RD               (check_rd),
        .A_RS1              (check_rs1),
        .A_RS2              (check_rs2),
        .A_CSR              (check_csr),
        .A_IMM              (check_imm),
        .B_ACCEPT           (cop_accept),
        .B_PC               (cop_pc),
        .B_RD               (cop_rd),
        .B_RS1              (cop_rs1),
        .B_RS2              (cop_rs2),

        // 後段との接続
        .SCHEDULE_A_ALLOW   (schedule_a_allow),
        .SCHEDULE_A_PC      (schedule_a_pc),
        .SCHEDULE_A_OPCODE  (schedule_a_opcode),
        .SCHEDULE_A_RD      (schedule_a_rd),
        .SCHEDULE_A_RS1     (schedule_a_rs1),
        .SCHEDULE_A_RS2     (schedule_a_rs2),
        .SCHEDULE_A_CSR     (schedule_a_csr),
        .SCHEDULE_A_IMM     (schedule_a_imm),
        .SCHEDULE_B_ALLOW   (schedule_b_allow)
    );

    /* ----- 4-2. レジスタアクセス ----- */
    // CSR
    wire [1:0]  trap_vec_mode;
    wire [31:0] trap_vec_base;
    wire        int_allow;

    wire [31:0] schedule_a_csr_data;
    wire        schedule_a_csr_valid;

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
        .RADDR              (check_csr),
        .RVALID             (schedule_a_csr_valid),
        .RDATA              (schedule_a_csr_data),
        .WREN               (memr_csr_w_en),
        .WADDR              (memr_csr_w_addr),
        .WDATA              (memr_csr_w_data),

        // フォワーディング
        .FWD_CSR_ADDR       (schedule_a_csr),
        .FWD_EXEC_EN        (exec_csr_w_en),
        .FWD_EXEC_ADDR      (exec_csr_w_addr),
        .FWD_EXEC_DATA      (exec_csr_w_data),
        .FWD_CUSHION_EN     (cushion_csr_w_en),
        .FWD_CUSHION_ADDR   (cushion_csr_w_addr),
        .FWD_CUSHION_DATA   (cushion_csr_w_data)
    );

    // RV32I
    wire [31:0] schedule_a_rs1_data, schedule_a_rs2_data;
    wire        schedule_a_rs1_valid, schedule_a_rs2_valid;

    reg_std_rv32i reg_std_rv32i_0 (
        // 制御
        .CLK                (CLK),
        .RST                (RST),
        .FLUSH              (flush),
        .STALL              (stall),
        .MEM_WAIT           (MEM_WAIT),

        // レジスタアクセス
        .A_RADDR            (check_rs1),
        .A_RVALID           (schedule_a_rs1_valid),
        .A_RDATA            (schedule_a_rs1_data),
        .B_RADDR            (check_rs2),
        .B_RVALID           (schedule_a_rs2_valid),
        .B_RDATA            (schedule_a_rs2_data),
        .WADDR              (memr_reg_w_rd),
        .WDATA              (memr_reg_w_data),

        // フォワーディング
        .FWD_REG_ADDR       (schedule_a_rd),
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
        .ALLOW              (schedule_a_allow),
        .PC                 (schedule_a_pc),
        .OPCODE             (schedule_a_opcode),
        .RD_ADDR            (schedule_a_rd),
        .RS1_ADDR           (schedule_a_rs1),
        .RS1_DATA           (schedule_a_rs1_data),
        .RS2_ADDR           (schedule_a_rs2),
        .RS2_DATA           (schedule_a_rs2_data),
        .CSR_ADDR           (schedule_a_csr),
        .CSR_DATA           (schedule_a_csr_data),
        .IMM                (schedule_a_imm),

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

        // 前段との接続
        .PC                     (exec_pc),
        .REG_W_EN               (exec_reg_w_en),
        .REG_W_RD               (exec_reg_w_rd),
        .REG_W_DATA             (exec_reg_w_data),
        .CSR_W_EN               (exec_csr_w_en),
        .CSR_W_ADDR             (exec_csr_w_addr),
        .CSR_W_DATA             (exec_csr_w_data),
        .MEM_R_EN               (exec_mem_r_en),
        .MEM_R_RD               (exec_mem_r_rd),
        .MEM_R_ADDR             (exec_mem_r_addr),
        .MEM_R_STRB             (exec_mem_r_strb),
        .MEM_R_SIGNED           (exec_mem_r_signed),
        .MEM_W_EN               (exec_mem_w_en),
        .MEM_W_ADDR             (exec_mem_w_addr),
        .MEM_W_STRB             (exec_mem_w_strb),
        .MEM_W_DATA             (exec_mem_w_data),
        .JMP_DO                 (exec_jmp_do),
        .JMP_PC                 (exec_jmp_pc),
        .EXC_EN                 (exec_exc_en),
        .EXC_CODE               (exec_exc_code),

        // 後段との接続
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
    wire [3:0]  memr_mem_w_strb;

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

        // 前段との接続
        .REG_W_RD               (cushion_reg_w_rd),
        .REG_W_DATA             (cushion_reg_w_data),
        .CSR_W_EN               (cushion_csr_w_en),
        .CSR_W_ADDR             (cushion_csr_w_addr),
        .CSR_W_DATA             (cushion_csr_w_data),
        .MEM_R_EN               (cushion_mem_r_en),
        .MEM_R_RD               (cushion_mem_r_rd),
        .MEM_R_ADDR             (cushion_mem_r_addr),
        .MEM_R_STRB             (cushion_mem_r_strb),
        .MEM_R_SIGNED           (cushion_mem_r_signed),
        .MEM_W_EN               (cushion_mem_w_en),
        .MEM_W_ADDR             (cushion_mem_w_addr),
        .MEM_W_STRB             (cushion_mem_w_strb),
        .MEM_W_DATA             (cushion_mem_w_data),
        .JMP_DO                 (cushion_jmp_do),
        .JMP_PC                 (cushion_jmp_pc),

        // 後段との接続
        .MEMR_REG_W_RD          (memr_reg_w_rd),
        .MEMR_REG_W_DATA        (memr_reg_w_data),
        .MEMR_CSR_W_EN          (memr_csr_w_en),
        .MEMR_CSR_W_ADDR        (memr_csr_w_addr),
        .MEMR_CSR_W_DATA        (memr_csr_w_data),
        .MEMR_MEM_W_EN          (memr_mem_w_en),
        .MEMR_MEM_W_STRB        (memr_mem_w_strb),
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
        .TRAP_JMP_TO        (trap_jmp_to),

        // 前段との接続
        .FETCH_PC           (fetch_pc),
        .DECODE_PC          (decode_pc),
        .CHECK_PC           (check_pc),
        .SCHEDULE_PC        (schedule_a_pc),
        .EXEC_PC            (exec_pc),
        .CUSHION_PC         (cushion_pc),
        .CUSHION_EXC_EN     (cushion_exc_en),
        .CUSHION_EXC_CODE   (cushion_exc_code)
    );

    /* ----- 8. メモリアクセス(w) ----- */
    assign DATA_WREN  = flush ? 1'b0 : memr_mem_w_en;
    assign DATA_WSTRB = flush ? 4'b0 : memr_mem_w_strb;
    assign DATA_WADDR = flush ? 32'b0 : memr_mem_w_addr;
    assign DATA_WDATA = flush ? 32'b0 : memr_mem_w_data;

endmodule

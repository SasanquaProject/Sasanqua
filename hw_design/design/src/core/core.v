module core
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
        input wire          MEM_WAIT
    );

    /* ----- パイプライン制御 ----- */
    wire flush = memr_jmp_do;
    wire stall = !reg_rs1_valid || !reg_rs2_valid || !reg_csr_valid;

    /* ----- 1. 命令フェッチ ----- */
    wire [31:0] inst_pc, inst_data;

    fetch fetch (
        // 制御
        .CLK        (CLK),
        .RST        (RST),
        .FLUSH      (flush),
        .NEW_PC     (memr_jmp_pc),
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

    /* ----- 2. 命令デコード1 ----- */
    wire [31:0] decode_1st_pc, decode_1st_imm_i, decode_1st_imm_s, decode_1st_imm_b, decode_1st_imm_u, decode_1st_imm_j;
    wire [6:0]  decode_1st_opcode, decode_1st_funct7;
    wire [4:0]  decode_1st_rd, decode_1st_rs1, decode_1st_rs2;
    wire [2:0]  decode_1st_funct3;

    decode_1st decode_1st (
        // 制御
        .CLK                (CLK),
        .RST                (RST),
        .FLUSH              (flush),
        .STALL              (stall),
        .MEM_WAIT           (MEM_WAIT),

        // フェッチ部との接続
        .INST_PC            (inst_pc),
        .INST_DATA          (inst_data),

        // デコード部2との接続
        .DECODE_1ST_PC      (decode_1st_pc),
        .DECODE_1ST_OPCODE  (decode_1st_opcode),
        .DECODE_1ST_RD      (decode_1st_rd),
        .DECODE_1ST_RS1     (decode_1st_rs1),
        .DECODE_1ST_RS2     (decode_1st_rs2),
        .DECODE_1ST_FUNCT3  (decode_1st_funct3),
        .DECODE_1ST_FUNCT7  (decode_1st_funct7),
        .DECODE_1ST_IMM_I   (decode_1st_imm_i),
        .DECODE_1ST_IMM_S   (decode_1st_imm_s),
        .DECODE_1ST_IMM_B   (decode_1st_imm_b),
        .DECODE_1ST_IMM_U   (decode_1st_imm_u),
        .DECODE_1ST_IMM_J   (decode_1st_imm_j)
    );

    /* ----- 3. 命令デコード2 ----- */
    wire [31:0] decode_2nd_pc, decode_2nd_imm;
    wire [11:0] decode_2nd_csr;
    wire [6:0]  decode_2nd_opcode, decode_2nd_funct7;
    wire [4:0]  decode_2nd_rd, decode_2nd_rs1, decode_2nd_rs2;
    wire [2:0]  decode_2nd_funct3;

    decode_2nd decode_2nd (
        // 制御
        .CLK                (CLK),
        .RST                (RST),
        .FLUSH              (flush),
        .STALL              (stall),
        .MEM_WAIT           (MEM_WAIT),

        // デコード部1との接続
        .DECODE_1ST_PC      (decode_1st_pc),
        .DECODE_1ST_OPCODE  (decode_1st_opcode),
        .DECODE_1ST_RD      (decode_1st_rd),
        .DECODE_1ST_RS1     (decode_1st_rs1),
        .DECODE_1ST_RS2     (decode_1st_rs2),
        .DECODE_1ST_FUNCT3  (decode_1st_funct3),
        .DECODE_1ST_FUNCT7  (decode_1st_funct7),
        .DECODE_1ST_IMM_I   (decode_1st_imm_i),
        .DECODE_1ST_IMM_S   (decode_1st_imm_s),
        .DECODE_1ST_IMM_B   (decode_1st_imm_b),
        .DECODE_1ST_IMM_U   (decode_1st_imm_u),
        .DECODE_1ST_IMM_J   (decode_1st_imm_j),

        // スケジューラ1との接続
        .DECODE_2ND_PC      (decode_2nd_pc),
        .DECODE_2ND_OPCODE  (decode_2nd_opcode),
        .DECODE_2ND_RD      (decode_2nd_rd),
        .DECODE_2ND_RS1     (decode_2nd_rs1),
        .DECODE_2ND_RS2     (decode_2nd_rs2),
        .DECODE_2ND_CSR     (decode_2nd_csr),
        .DECODE_2ND_FUNCT3  (decode_2nd_funct3),
        .DECODE_2ND_FUNCT7  (decode_2nd_funct7),
        .DECODE_2ND_IMM     (decode_2nd_imm)
    );

    /* ----- 4-1. スケジューリング1 ----- */
    wire [31:0] schedule_1st_pc, schedule_1st_imm;
    wire [11:0] schedule_1st_csr;
    wire [6:0]  schedule_1st_opcode, schedule_1st_funct7;
    wire [4:0]  schedule_1st_rd, schedule_1st_rs1, schedule_1st_rs2;
    wire [2:0]  schedule_1st_funct3;

    schedule_1st schedule_1st (
        // 制御
        .CLK                (CLK),
        .RST                (RST),
        .FLUSH              (flush),
        .STALL              (stall),
        .MEM_WAIT           (MEM_WAIT),

        // デコード部2との接続
        .DECODE_2ND_PC      (decode_2nd_pc),
        .DECODE_2ND_OPCODE  (decode_2nd_opcode),
        .DECODE_2ND_RD      (decode_2nd_rd),
        .DECODE_2ND_CSR     (decode_2nd_csr),
        .DECODE_2ND_FUNCT3  (decode_2nd_funct3),
        .DECODE_2ND_FUNCT7  (decode_2nd_funct7),
        .DECODE_2ND_IMM     (decode_2nd_imm),

        // 実行部との接続
        .SCHEDULE_1ST_PC    (schedule_1st_pc),
        .SCHEDULE_1ST_OPCODE(schedule_1st_opcode),
        .SCHEDULE_1ST_RD    (schedule_1st_rd),
        .SCHEDULE_1ST_CSR   (schedule_1st_csr),
        .SCHEDULE_1ST_FUNCT3(schedule_1st_funct3),
        .SCHEDULE_1ST_FUNCT7(schedule_1st_funct7),
        .SCHEDULE_1ST_IMM   (schedule_1st_imm)
    );

    /* ----- 4-2. レジスタアクセス ----- */
    // CSR
    wire [31:0] reg_csr_data;
    wire [31:0] reg_csr_addr;
    wire        reg_csr_valid;

    csr csr (
        // 制御
        .CLK                (CLK),
        .RST                (RST),
        .FLUSH              (flush),
        .STALL              (stall),
        .MEM_WAIT           (MEM_WAIT),

        // レジスタアクセス
        .RIADDR             (decode_2nd_csr),
        .RVALID             (reg_csr_valid),
        .ROADDR             (reg_csr_addr),
        .RDATA              (reg_csr_data),
        .WREN               (memr_csr_w_en),
        .WADDR              (memr_csr_w_addr),
        .WDATA              (memr_csr_w_data),

        // フォワーディング
        .FWD_CSR_ADDR       (schedule_1st_csr),
        .FWD_EXEC_EN        (csr_w_en),
        .FWD_EXEC_ADDR      (csr_w_rd),
        .FWD_EXEC_DATA      (csr_w_data),
        .FWD_CUSHION_EN     (cushion_csr_w_en),
        .FWD_CUSHION_ADDR   (cushion_csr_w_rd),
        .FWD_CUSHION_DATA   (cushion_csr_w_data)
    );

    // RV32I
    wire [31:0] reg_rs1_data, reg_rs2_data;
    wire [4:0]  reg_rs1_addr, reg_rs2_addr;
    wire        reg_rs1_valid, reg_rs2_valid;

    rv32i_reg rv32i_reg (
        // 制御
        .CLK                (CLK),
        .RST                (RST),
        .FLUSH              (flush),
        .STALL              (stall),
        .MEM_WAIT           (MEM_WAIT),

        // レジスタアクセス
        .A_RIADDR           (decode_2nd_rs1),
        .A_RVALID           (reg_rs1_valid),
        .A_ROADDR           (reg_rs1_addr),
        .A_RDATA            (reg_rs1_data),
        .B_RIADDR           (decode_2nd_rs2),
        .B_RVALID           (reg_rs2_valid),
        .B_ROADDR           (reg_rs2_addr),
        .B_RDATA            (reg_rs2_data),
        .WADDR              (memr_reg_w_rd),
        .WDATA              (memr_reg_w_data),

        // フォワーディング
        .FWD_REG_ADDR       (schedule_1st_rd),
        .FWD_EXEC_EN        (reg_w_en),
        .FWD_EXEC_ADDR      (reg_w_rd),
        .FWD_EXEC_DATA      (reg_w_data),
        .FWD_CUSHION_EN     (cushion_reg_w_en),
        .FWD_CUSHION_ADDR   (cushion_reg_w_rd),
        .FWD_CUSHION_DATA   (cushion_reg_w_data)
    );

    /* ----- 5. 実行 ----- */
    wire        reg_w_en, mem_r_en, mem_r_signed, csr_w_en, mem_w_en, jmp_do;
    wire [31:0] reg_w_data, csr_w_data, mem_r_addr, mem_w_addr, mem_w_data, jmp_pc;
    wire [11:0] csr_w_addr;
    wire [4:0]  reg_w_rd, mem_r_rd;
    wire [3:0]  mem_r_strb, mem_w_strb;

    exec exec (
        // 制御
        .CLK            (CLK),
        .RST            (RST),
        .FLUSH          (flush),
        .STALL          (stall),
        .MEM_WAIT       (MEM_WAIT),

        // 前段との接続
        .PC             (schedule_1st_pc),
        .OPCODE         (schedule_1st_opcode),
        .RD_ADDR        (schedule_1st_rd),
        .RS1_ADDR       (reg_rs1_addr),
        .RS1_DATA       (reg_rs1_data),
        .RS2_ADDR       (reg_rs2_addr),
        .RS2_DATA       (reg_rs2_data),
        .CSR_ADDR       (reg_csr_addr),
        .CSR_DATA       (reg_csr_data),
        .FUNCT3         (schedule_1st_funct3),
        .FUNCT7         (schedule_1st_funct7),
        .IMM            (schedule_1st_imm),

        // 後段との接続
        .REG_W_EN       (reg_w_en),
        .REG_W_RD       (reg_w_rd),
        .REG_W_DATA     (reg_w_data),
        .CSR_W_EN       (csr_w_en),
        .CSR_W_ADDR     (csr_w_addr),
        .CSR_W_DATA     (csr_w_data),
        .MEM_R_EN       (mem_r_en),
        .MEM_R_RD       (mem_r_rd),
        .MEM_R_ADDR     (mem_r_addr),
        .MEM_R_STRB     (mem_r_strb),
        .MEM_R_SIGNED   (mem_r_signed),
        .MEM_W_EN       (mem_w_en),
        .MEM_W_ADDR     (mem_w_addr),
        .MEM_W_STRB     (mem_w_strb),
        .MEM_W_DATA     (mem_w_data),
        .JMP_DO         (jmp_do),
        .JMP_PC         (jmp_pc)
    );

    /* ----- 6. 実行部待機 ------ */
    wire        cushion_reg_w_en, cushion_mem_r_en, cushion_mem_r_signed, cushion_csr_w_en, cushion_mem_w_en, cushion_jmp_do;
    wire [31:0] cushion_reg_w_data, cushion_csr_w_data, cushion_mem_r_addr, cushion_mem_w_addr, cushion_mem_w_data, cushion_jmp_pc;
    wire [11:0] cushion_csr_w_addr;
    wire [4:0]  cushion_reg_w_rd, cushion_mem_r_rd;
    wire [3:0]  cushion_mem_r_strb, cushion_mem_w_strb;

    cushion cushion (
        // 制御
        .CLK                    (CLK),
        .RST                    (RST),
        .FLUSH                  (flush),
        .MEM_WAIT               (MEM_WAIT),

        // 実行部との接続
        .EXEC_REG_W_EN          (reg_w_en),
        .EXEC_REG_W_RD          (reg_w_rd),
        .EXEC_REG_W_DATA        (reg_w_data),
        .EXEC_CSR_W_EN          (csr_w_en),
        .EXEC_CSR_W_ADDR        (csr_w_addr),
        .EXEC_CSR_W_DATA        (csr_w_data),
        .EXEC_MEM_R_EN          (mem_r_en),
        .EXEC_MEM_R_RD          (mem_r_rd),
        .EXEC_MEM_R_ADDR        (mem_r_addr),
        .EXEC_MEM_R_STRB        (mem_r_strb),
        .EXEC_MEM_R_SIGNED      (mem_r_signed),
        .EXEC_MEM_W_EN          (mem_w_en),
        .EXEC_MEM_W_ADDR        (mem_w_addr),
        .EXEC_MEM_W_STRB        (mem_w_strb),
        .EXEC_MEM_W_DATA        (mem_w_data),
        .EXEC_JMP_DO            (jmp_do),
        .EXEC_JMP_PC            (jmp_pc),

        // メモリアクセス部(r)との接続
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
        .CUSHION_JMP_PC         (cushion_jmp_pc)
    );

    /* ----- 7. メモリアクセス(r) ----- */
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

    /* ----- 8. メモリアクセス(w) ----- */
    assign DATA_WREN    = memr_mem_w_en;
    assign DATA_WADDR   = memr_mem_w_addr;
    assign DATA_WDATA   = memr_mem_w_data;

endmodule

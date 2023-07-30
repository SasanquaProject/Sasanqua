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
        // input wire          DATA_WREN,
        // input wire [31:0]   DATA_WRADDR,
        // input wire [31:0]   DATA_WRDATA,
        output wire         DATA_RDEN,
        output wire [31:0]  DATA_RIADDR,
        input wire  [31:0]  DATA_ROADDR,
        input wire          DATA_RVALID,
        input wire  [31:0]  DATA_RDATA,

        // ハザード
        input wire          MEM_WAIT
    );

    assign DATA_RDEN    = 1'b0;
    assign DATA_RIADDR  = 32'b0;

    /* ----- 1. 命令フェッチ ----- */
    wire        inst_valid;
    wire [31:0] inst_pc, inst_data;

    assign inst_valid   = INST_RVALID;
    assign inst_pc      = INST_ROADDR;
    assign inst_data    = INST_RDATA;

    fetch fetch (
        // 制御
        .CLK        (CLK),
        .RST        (RST),

        // メモリアクセス
        .MEM_WAIT   (MEM_WAIT),
        .INST_RDEN  (INST_RDEN),
        .INST_RIADDR(INST_RIADDR)
    );

    /* ----- 2. 命令デコード1 ----- */
    wire        decode_1st_valid;
    wire [31:0] decode_1st_pc, decode_1st_imm_i, decode_1st_imm_s, decode_1st_imm_b, decode_1st_imm_u, decode_1st_imm_j;
    wire [6:0]  decode_1st_opcode, decode_1st_funct7;
    wire [4:0]  decode_1st_rd, decode_1st_rs1, decode_1st_rs2;
    wire [2:0]  decode_1st_funct3;

    decode_1st decode_1st (
        // 制御
        .CLK                (CLK),
        .RST                (RST),

        // フェッチ部との接続
        .INST_VALID         (inst_valid),
        .INST_PC            (inst_pc),
        .INST_DATA          (inst_data),

        // デコード部2との接続
        .DECODE_1ST_VALID   (decode_1st_valid),
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
    wire        decode_2nd_valid;
    wire [31:0] decode_2nd_pc, decode_2nd_imm;
    wire [6:0]  decode_2nd_opcode, decode_2nd_funct7;
    wire [4:0]  decode_2nd_rd, decode_2nd_rs1, decode_2nd_rs2;
    wire [2:0]  decode_2nd_funct3;

    decode_2nd decode_2nd (
        // 制御
        .CLK                (CLK),
        .RST                (RST),

        // デコード部1との接続
        .DECODE_1ST_VALID   (decode_1st_valid),
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
        .DECODE_2ND_VALID   (decode_2nd_valid),
        .DECODE_2ND_PC      (decode_2nd_pc),
        .DECODE_2ND_OPCODE  (decode_2nd_opcode),
        .DECODE_2ND_RD      (decode_2nd_rd),
        .DECODE_2ND_RS1     (decode_2nd_rs1),
        .DECODE_2ND_RS2     (decode_2nd_rs2),
        .DECODE_2ND_FUNCT3  (decode_2nd_funct3),
        .DECODE_2ND_FUNCT7  (decode_2nd_funct7),
        .DECODE_2ND_IMM     (decode_2nd_imm)
    );

    /* ----- 4-1. スケジューリング1 ----- */
    wire        schedule_1st_valid;
    wire [31:0] schedule_1st_pc, schedule_1st_imm;
    wire [6:0]  schedule_1st_opcode, schedule_1st_funct7;
    wire [4:0]  schedule_1st_rd, schedule_1st_rs1, schedule_1st_rs2;
    wire [2:0]  schedule_1st_funct3;

    schedule_1st schedule_1st (
        // 制御
        .CLK                (CLK),
        .RST                (RST),

        // デコード部2との接続
        .DECODE_2ND_VALID   (decode_2nd_valid),
        .DECODE_2ND_PC      (decode_2nd_pc),
        .DECODE_2ND_OPCODE  (decode_2nd_opcode),
        .DECODE_2ND_RD      (decode_2nd_rd),
        .DECODE_2ND_FUNCT3  (decode_2nd_funct3),
        .DECODE_2ND_FUNCT7  (decode_2nd_funct7),
        .DECODE_2ND_IMM     (decode_2nd_imm),

        // 実行部との接続
        .SCHEDULE_1ST_VALID (schedule_1st_valid),
        .SCHEDULE_1ST_PC    (schedule_1st_pc),
        .SCHEDULE_1ST_OPCODE(schedule_1st_opcode),
        .SCHEDULE_1ST_RD    (schedule_1st_rd),
        .SCHEDULE_1ST_FUNCT3(schedule_1st_funct3),
        .SCHEDULE_1ST_FUNCT7(schedule_1st_funct7),
        .SCHEDULE_1ST_IMM   (schedule_1st_imm)
    );

    /* ----- 4-2. レジスタアクセス ----- */
    wire [31:0] reg_rs1_v, reg_rs2_v;
    wire [4:0]  reg_rs1, reg_rs2;

    register register (
        // 制御
        .CLK            (CLK),
        .RST            (RST),

        // レジスタアクセス(rv32i)
        .REG_IR_I_A     (decode_2nd_rs1),
        .REG_IR_I_B     (decode_2nd_rs2),
        .REG_IR_O_A     (reg_rs1),
        .REG_IR_O_AV    (reg_rs1_v),
        .REG_IR_O_B     (reg_rs2),
        .REG_IR_O_BV    (reg_rs2_v),
        .REG_IW_I_A     (memr_reg_w_rd),
        .REG_IW_I_AV    (memr_reg_w_data)
    );

    /* ----- 5. 実行 ----- */
    wire        mem_r_valid, mem_r_signed, mem_w_valid, jmp_do;
    wire [31:0] reg_w_data, mem_r_addr, mem_w_addr, mem_w_data, jmp_pc;
    wire [4:0]  reg_w_rd, mem_r_rd;
    wire [3:0]  mem_r_strb, mem_w_strb;

    exec exec (
        // 制御
        .CLK            (CLK),
        .RST            (RST),

        // データフォワーディング
        .REG_FWD_A      (cushion_reg_w_rd),
        .REG_FWD_AV     (cushion_reg_w_data),
        .REG_FWD_B      (memr_reg_w_rd),
        .REG_FWD_BV     (memr_reg_w_data),
        .REG_FWD_C      (memw_reg_w_rd),
        .REG_FWD_CV     (memw_reg_w_data),

        // 前段との接続
        .VALID          (schedule_1st_valid),
        .PC             (schedule_1st_pc),
        .OPCODE         (schedule_1st_opcode),
        .RD             (schedule_1st_rd),
        .RS1            (reg_rs1),
        .RS1_V          (reg_rs1_v),
        .RS2            (reg_rs2),
        .RS2_V          (reg_rs2_v),
        .FUNCT3         (schedule_1st_funct3),
        .FUNCT7         (schedule_1st_funct7),
        .IMM            (schedule_1st_imm),

        // 後段との接続
        .REG_W_RD       (reg_w_rd),
        .REG_W_DATA     (reg_w_data),
        .MEM_R_VALID    (mem_r_valid),
        .MEM_R_RD       (mem_r_rd),
        .MEM_R_ADDR     (mem_r_addr),
        .MEM_R_STRB     (mem_r_strb),
        .MEM_R_SIGNED   (mem_r_signed),
        .MEM_W_VALID    (mem_w_valid),
        .MEM_W_ADDR     (mem_w_addr),
        .MEM_W_STRB     (mem_w_strb),
        .MEM_W_DATA     (mem_w_data),
        .JMP_DO         (jmp_do),
        .JMP_PC         (jmp_pc)
    );

    /* ----- 6. 実行部待機 ------ */
    wire        cushion_mem_r_valid, cushion_mem_r_signed, cushion_mem_w_valid;
    wire [31:0] cushion_reg_w_data, cushion_mem_r_addr, cushion_mem_w_addr, cushion_mem_w_data;
    wire [4:0]  cushion_reg_w_rd, cushion_mem_r_rd;
    wire [3:0]  cushion_mem_r_strb, cushion_mem_w_strb;

    cushion cushion (
        // 制御
        .CLK                    (CLK),
        .RST                    (RST),

        // 実行部との接続
        .EXEC_REG_W_RD          (reg_w_rd),
        .EXEC_REG_W_DATA        (reg_w_data),
        .EXEC_MEM_R_VALID       (mem_r_valid),
        .EXEC_MEM_R_RD          (mem_r_rd),
        .EXEC_MEM_R_ADDR        (mem_r_addr),
        .EXEC_MEM_R_STRB        (mem_r_strb),
        .EXEC_MEM_R_SIGNED      (mem_r_signed),
        .EXEC_MEM_W_VALID       (mem_w_valid),
        .EXEC_MEM_W_ADDR        (mem_w_addr),
        .EXEC_MEM_W_STRB        (mem_w_strb),
        .EXEC_MEM_W_DATA        (mem_w_data),

        // メモリアクセス部(r)との接続
        .CUSHION_REG_W_RD       (cushion_reg_w_rd),
        .CUSHION_REG_W_DATA     (cushion_reg_w_data),
        .CUSHION_MEM_R_VALID    (cushion_mem_r_valid),
        .CUSHION_MEM_R_RD       (cushion_mem_r_rd),
        .CUSHION_MEM_R_ADDR     (cushion_mem_r_addr),
        .CUSHION_MEM_R_STRB     (cushion_mem_r_strb),
        .CUSHION_MEM_R_SIGNED   (cushion_mem_r_signed),
        .CUSHION_MEM_W_VALID    (cushion_mem_w_valid),
        .CUSHION_MEM_W_ADDR     (cushion_mem_w_addr),
        .CUSHION_MEM_W_STRB     (cushion_mem_w_strb),
        .CUSHION_MEM_W_DATA     (cushion_mem_w_data)
    );

    /* ----- 7. メモリアクセス(r) ----- */
    wire        memr_mem_w_valid;
    wire [31:0] memr_reg_w_data, memr_mem_w_addr, memr_mem_w_data;
    wire [4:0]  memr_reg_w_rd;
    wire [3:0]  memr_mem_w_strb;

    mread mread (
        // 制御
        .CLK                    (CLK),
        .RST                    (RST),

        // 実行待機部との接続
        .CUSHION_REG_W_RD       (cushion_reg_w_rd),
        .CUSHION_REG_W_DATA     (cushion_reg_w_data),
        .CUSHION_MEM_R_VALID    (cushion_mem_r_valid),
        .CUSHION_MEM_R_RD       (cushion_mem_r_rd),
        .CUSHION_MEM_R_ADDR     (cushion_mem_r_addr),
        .CUSHION_MEM_R_STRB     (cushion_mem_r_strb),
        .CUSHION_MEM_R_SIGNED   (cushion_mem_r_signed),
        .CUSHION_MEM_W_VALID    (cushion_mem_w_valid),
        .CUSHION_MEM_W_ADDR     (cushion_mem_w_addr),
        .CUSHION_MEM_W_STRB     (cushion_mem_w_strb),
        .CUSHION_MEM_W_DATA     (cushion_mem_w_data),

        // メモリアクセス(w)との接続
        .MEMR_REG_W_RD          (memr_reg_w_rd),
        .MEMR_REG_W_DATA        (memr_reg_w_data),
        .MEMR_MEM_W_VALID       (memr_mem_w_valid),
        .MEMR_MEM_W_ADDR        (memr_mem_w_addr),
        .MEMR_MEM_W_STRB        (memr_mem_w_strb),
        .MEMR_MEM_W_DATA        (memr_mem_w_data)
    );

    /* ----- 8. メモリアクセス(w) ----- */
    reg  [4:0]  memw_reg_w_rd;
    reg  [31:0] memw_reg_w_data;

    always @ (posedge CLK) begin
        memw_reg_w_rd <= memr_reg_w_rd;
        memw_reg_w_data <= memr_reg_w_data;
    end

    mwrite mwrite (
        // 制御
        .CLK                    (CLK),
        .RST                    (RST),

        // メモリアクセス(w)との接続
        .MEMR_MEM_W_VALID       (memr_mem_w_valid),
        .MEMR_MEM_W_ADDR        (memr_mem_w_addr),
        .MEMR_MEM_W_STRB        (memr_mem_w_strb),
        .MEMR_MEM_W_DATA        (memr_mem_w_data)
    );

endmodule

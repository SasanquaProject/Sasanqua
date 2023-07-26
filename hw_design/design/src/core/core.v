module core
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,

        /* ----- メモリアクセス信号 ----- */
        // 命令
        output reg          INST_RDEN,
        output reg  [31:0]  INST_RADDR,
        input wire          INST_RVALID,
        input wire  [31:0]  INST_RDATA,

        // データ
        // input wire          DATA_WREN,
        // input wire [31:0]   DATA_WRADDR,
        // input wire [31:0]   DATA_WRDATA,
        output wire         DATA_RDEN,
        output wire [31:0]  DATA_RADDR,
        input wire          DATA_RVALID,
        input wire  [31:0]  DATA_RDATA,

        // ハザード
        input wire          MEM_WAIT
    );

    assign DATA_RDEN    = 1'b0;
    assign DATA_RADDR   = 32'b0;

    /* ----- 1. 命令フェッチ ----- */
    wire        inst_valid;
    wire [31:0] inst_addr, inst_data;

    assign inst_valid   = INST_RVALID;
    assign inst_addr    = INST_RADDR;
    assign inst_data    = INST_RDATA;

    always @ (posedge CLK) begin
        if (RST) begin
            INST_RDEN <= 1'b0;
            INST_RADDR <= 32'hffff_fffc;
        end
        else if (!MEM_WAIT) begin
            INST_RDEN <= 1'b1;
            INST_RADDR <= INST_RADDR + 32'd4;
        end
    end

    /* ----- 2. 命令デコード1 ----- */
    wire        decode1_valid;
    wire [31:0] decode1_pc, decode1_imm_i, decode1_imm_s, decode1_imm_b, decode1_imm_u, decode1_imm_j;
    wire [6:0]  decode1_opcode, decode1_funct7;
    wire [4:0]  decode1_rd, decode1_rs1, decode1_rs2;
    wire [2:0]  decode1_funct3;

    decode_1 decode_1 (
        // 制御
        .CLK            (CLK),
        .RST            (RST),

        // フェッチ部との接続
        .INST_VALID     (inst_valid),
        .INST_PC        (inst_addr),
        .INST_DATA      (inst_data),

        // デコード部2との接続
        .DECODE1_VALID  (decode1_valid),
        .DECODE1_PC     (decode1_pc),
        .DECODE1_OPCODE (decode1_opcode),
        .DECODE1_RD     (decode1_rd),
        .DECODE1_RS1    (decode1_rs1),
        .DECODE1_RS2    (decode1_rs2),
        .DECODE1_FUNCT3 (decode1_funct3),
        .DECODE1_FUNCT7 (decode1_funct7),
        .DECODE1_IMM_I  (decode1_imm_i),
        .DECODE1_IMM_S  (decode1_imm_s),
        .DECODE1_IMM_B  (decode1_imm_b),
        .DECODE1_IMM_U  (decode1_imm_u),
        .DECODE1_IMM_J  (decode1_imm_j)
    );

    /* ----- 3-1. 命令デコード2 ----- */
    wire        decode2_valid;
    wire [31:0] decode2_pc, decode2_imm;
    wire [6:0]  decode2_opcode, decode2_funct7;
    wire [4:0]  decode2_rd;
    wire [2:0]  decode2_funct3;

    decode_2 decode_2 (
        // 制御
        .CLK            (CLK),
        .RST            (RST),

        // デコード部1との接続
        .DECODE1_VALID  (decode1_valid),
        .DECODE1_PC     (decode1_pc),
        .DECODE1_OPCODE (decode1_opcode),
        .DECODE1_RD     (decode1_rd),
        .DECODE1_FUNCT3 (decode1_funct3),
        .DECODE1_FUNCT7 (decode1_funct7),
        .DECODE1_IMM_I  (decode1_imm_i),
        .DECODE1_IMM_S  (decode1_imm_s),
        .DECODE1_IMM_B  (decode1_imm_b),
        .DECODE1_IMM_U  (decode1_imm_u),
        .DECODE1_IMM_J  (decode1_imm_j),

        .DECODE2_VALID  (decode2_valid),
        .DECODE2_PC     (decode2_pc),
        .DECODE2_OPCODE (decode2_opcode),
        .DECODE2_RD     (decode2_rd),
        .DECODE2_FUNCT3 (decode2_funct3),
        .DECODE2_FUNCT7 (decode2_funct7),
        .DECODE2_IMM    (decode2_imm)
    );

    /* ----- 3-2. レジスタアクセス ----- */
    wire [31:0] reg_rs1_v, reg_rs2_v;

    register register (
        // 制御
        .CLK        (CLK),
        .RST        (RST),

        // レジスタアクセス(rv32i)
        .REG_IR_A   (decode1_rs1),
        .REG_IR_B   (decode1_rs2),
        .REG_IR_AV  (reg_rs1_v),
        .REG_IR_BV  (reg_rs2_v)
    );

    /* ----- 4. 実行 ----- */
    exec exec (
        // 制御
        .CLK    (CLK),
        .RST    (RST)
    );

    /* ----- 5. メモリアクセス ----- */


endmodule

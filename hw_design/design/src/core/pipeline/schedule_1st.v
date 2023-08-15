module schedule_1st
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          FLUSH,
        input wire          STALL,
        input wire          MEM_WAIT,

        /* ----- デコード部2との接続 ----- */
        input wire  [31:0]  DECODE_2ND_PC,
        input wire  [6:0]   DECODE_2ND_OPCODE,
        input wire  [4:0]   DECODE_2ND_RD,
        input wire  [2:0]   DECODE_2ND_FUNCT3,
        input wire  [6:0]   DECODE_2ND_FUNCT7,
        input wire  [31:0]  DECODE_2ND_IMM,

        /* ----- 実行部との接続 ----- */
        output wire [31:0]  SCHEDULE_1ST_PC,
        output wire [6:0]   SCHEDULE_1ST_OPCODE,
        output wire [4:0]   SCHEDULE_1ST_RD,
        output wire [2:0]   SCHEDULE_1ST_FUNCT3,
        output wire [6:0]   SCHEDULE_1ST_FUNCT7,
        output wire [31:0]  SCHEDULE_1ST_IMM
    );

    /* ----- 入力取り込み ----- */
    reg  [31:0] decode_2nd_pc, decode_2nd_imm;
    reg  [6:0]  decode_2nd_opcode, decode_2nd_funct7;
    reg  [4:0]  decode_2nd_rd;
    reg  [2:0]  decode_2nd_funct3;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            decode_2nd_pc <= 32'b0;
            decode_2nd_opcode <= 7'b0;
            decode_2nd_rd <= 5'b0;
            decode_2nd_funct3 <= 3'b0;
            decode_2nd_funct7 <= 7'b0;
            decode_2nd_imm <= 32'b0;
        end
        else if (STALL || MEM_WAIT) begin
            // do nothing
        end
        else begin
            decode_2nd_pc <= DECODE_2ND_PC;
            decode_2nd_opcode <= DECODE_2ND_OPCODE;
            decode_2nd_rd <= DECODE_2ND_RD;
            decode_2nd_funct3 <= DECODE_2ND_FUNCT3;
            decode_2nd_funct7 <= DECODE_2ND_FUNCT7;
            decode_2nd_imm <= DECODE_2ND_IMM;
        end
    end

    /* ----- 出力(仮) ----- */
    assign SCHEDULE_1ST_PC      = decode_2nd_pc;
    assign SCHEDULE_1ST_OPCODE  = decode_2nd_opcode;
    assign SCHEDULE_1ST_RD      = decode_2nd_rd;
    assign SCHEDULE_1ST_FUNCT3  = decode_2nd_funct3;
    assign SCHEDULE_1ST_FUNCT7  = decode_2nd_funct7;
    assign SCHEDULE_1ST_IMM     = decode_2nd_imm;

endmodule

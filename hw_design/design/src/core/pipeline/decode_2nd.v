module decode_2nd
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          FLUSH,
        input wire          STALL,
        input wire          MEM_WAIT,

        /* ----- デコード部2との接続 ----- */
        input wire [31:0]   DECODE_1ST_PC,
        input wire [6:0]    DECODE_1ST_OPCODE,
        input wire [4:0]    DECODE_1ST_RD,
        input wire [4:0]    DECODE_1ST_RS1,
        input wire [4:0]    DECODE_1ST_RS2,
        input wire [2:0]    DECODE_1ST_FUNCT3,
        input wire [6:0]    DECODE_1ST_FUNCT7,
        input wire [31:0]   DECODE_1ST_IMM,

        /* ----- スケジューラ1との接続 ----- */
        output wire [31:0]  DECODE_2ND_PC,
        output wire [6:0]   DECODE_2ND_OPCODE,
        output wire [4:0]   DECODE_2ND_RD,
        output wire [4:0]   DECODE_2ND_RS1,
        output wire [4:0]   DECODE_2ND_RS2,
        output wire [11:0]  DECODE_2ND_CSR,
        output wire [2:0]   DECODE_2ND_FUNCT3,
        output wire [6:0]   DECODE_2ND_FUNCT7,
        output wire [31:0]  DECODE_2ND_IMM
    );

    /* ----- 入力取り込み ----- */
    reg  [31:0] decode_1st_pc, decode_1st_imm;
    reg  [6:0]  decode_1st_opcode, decode_1st_funct7;
    reg  [4:0]  decode_1st_rd, decode_1st_rs1, decode_1st_rs2;
    reg  [2:0]  decode_1st_funct3;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            decode_1st_pc <= 32'b0;
            decode_1st_opcode <= 7'b0;
            decode_1st_rd <= 5'b0;
            decode_1st_rs1 <= 5'b0;
            decode_1st_rs2 <= 5'b0;
            decode_1st_funct3 <= 3'b0;
            decode_1st_funct7 <= 7'b0;
            decode_1st_imm <= 32'b0;
        end
        else if (STALL || MEM_WAIT) begin
            // do nothing
        end
        else begin
            decode_1st_pc <= DECODE_1ST_PC;
            decode_1st_opcode <= DECODE_1ST_OPCODE;
            decode_1st_rd <= DECODE_1ST_RD;
            decode_1st_rs1 <= DECODE_1ST_RS1;
            decode_1st_rs2 <= DECODE_1ST_RS2;
            decode_1st_funct3 <= DECODE_1ST_FUNCT3;
            decode_1st_funct7 <= DECODE_1ST_FUNCT7;
            decode_1st_imm <= DECODE_1ST_IMM;
        end
    end

    /* ----- デコード ----- */
    assign DECODE_2ND_PC       = decode_1st_pc;
    assign DECODE_2ND_OPCODE   = decode_1st_opcode;
    assign DECODE_2ND_RD       = decode_1st_rd;
    assign DECODE_2ND_RS1      = decode_1st_rs1;
    assign DECODE_2ND_RS2      = decode_1st_rs2;
    assign DECODE_2ND_CSR      = decode_1st_imm[11:0];
    assign DECODE_2ND_FUNCT3   = decode_1st_funct3;
    assign DECODE_2ND_FUNCT7   = decode_1st_funct7;
    assign DECODE_2ND_IMM      = decode_1st_imm;

endmodule

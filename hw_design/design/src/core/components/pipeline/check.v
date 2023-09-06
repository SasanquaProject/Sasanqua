module check
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          FLUSH,
        input wire          STALL,
        input wire          MEM_WAIT,

        /* ----- デコード部2との接続 ----- */
        input wire [31:0]   DECODE_PC,
        input wire [6:0]    DECODE_OPCODE,
        input wire [4:0]    DECODE_RD,
        input wire [4:0]    DECODE_RS1,
        input wire [4:0]    DECODE_RS2,
        input wire [2:0]    DECODE_FUNCT3,
        input wire [6:0]    DECODE_FUNCT7,
        input wire [31:0]   DECODE_IMM,

        /* ----- スケジューラ1との接続 ----- */
        output wire [31:0]  CHECK_PC,
        output wire [6:0]   CHECK_OPCODE,
        output wire [4:0]   CHECK_RD,
        output wire [4:0]   CHECK_RS1,
        output wire [4:0]   CHECK_RS2,
        output wire [11:0]  CHECK_CSR,
        output wire [2:0]   CHECK_FUNCT3,
        output wire [6:0]   CHECK_FUNCT7,
        output wire [31:0]  CHECK_IMM
    );

    /* ----- 入力取り込み ----- */
    reg  [31:0] decode_pc, decode_imm;
    reg  [6:0]  decode_opcode, decode_funct7;
    reg  [4:0]  decode_rd, decode_rs1, decode_rs2;
    reg  [2:0]  decode_funct3;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            decode_pc <= 32'b0;
            decode_opcode <= 7'b0;
            decode_rd <= 5'b0;
            decode_rs1 <= 5'b0;
            decode_rs2 <= 5'b0;
            decode_funct3 <= 3'b0;
            decode_funct7 <= 7'b0;
            decode_imm <= 32'b0;
        end
        else if (STALL || MEM_WAIT) begin
            // do nothing
        end
        else begin
            decode_pc <= DECODE_PC;
            decode_opcode <= DECODE_OPCODE;
            decode_rd <= DECODE_RD;
            decode_rs1 <= DECODE_RS1;
            decode_rs2 <= DECODE_RS2;
            decode_funct3 <= DECODE_FUNCT3;
            decode_funct7 <= DECODE_FUNCT7;
            decode_imm <= DECODE_IMM;
        end
    end

    /* ----- デコード ----- */
    wire is_unimp = decode_imm == 32'hffff_ffff;

    assign CHECK_PC     = decode_pc;
    assign CHECK_OPCODE = is_unimp ? 7'b1101111 : decode_opcode;
    assign CHECK_RD     = is_unimp ? 5'b0 : decode_rd;
    assign CHECK_RS1    = is_unimp ? 5'b0 : decode_rs1;
    assign CHECK_RS2    = is_unimp ? 5'b0 : decode_rs2;
    assign CHECK_CSR    = is_unimp ? 5'b0 : decode_imm[11:0];
    assign CHECK_FUNCT3 = is_unimp ? 5'b0 : decode_funct3;
    assign CHECK_FUNCT7 = is_unimp ? 5'b0 : decode_funct7;
    assign CHECK_IMM    = is_unimp ? 32'b0 : decode_imm;

endmodule

module check #
    (
        parameter COP_NUMS = 32'd1,
        parameter PNUMS = COP_NUMS+1
    )
    (
        /* ----- 制御 ----- */
        input wire                  CLK,
        input wire                  RST,
        input wire                  FLUSH,
        input wire                  STALL,
        input wire                  MEM_WAIT,

        /* ----- デコード部2との接続 ----- */
        input wire  [(32*PNUMS-1):0] PC,
        input wire  [(17*PNUMS-1):0] OPCODE,
        input wire  [( 5*PNUMS-1):0] RD,
        input wire  [( 5*PNUMS-1):0] RS1,
        input wire  [( 5*PNUMS-1):0] RS2,
        input wire  [(32*PNUMS-1):0] IMM,

        /* ----- スケジューラ1との接続 ----- */
        output wire [( 1*PNUMS-1):0] CHECK_ACCEPT,
        output wire [(32*PNUMS-1):0] CHECK_PC,
        output wire [(17*PNUMS-1):0] CHECK_OPCODE,
        output wire [( 5*PNUMS-1):0] CHECK_RD,
        output wire [( 5*PNUMS-1):0] CHECK_RS1,
        output wire [( 5*PNUMS-1):0] CHECK_RS2,
        output wire [(12*PNUMS-1):0] CHECK_CSR,
        output wire [(32*PNUMS-1):0] CHECK_IMM
    );

    /* ----- 入力取り込み ----- */
    reg [(32*PNUMS-1):0] pc, imm;
    reg [(17*PNUMS-1):0] opcode;
    reg [( 5*PNUMS-1):0] rd, rs1, rs2;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            pc <= 'b0;
            opcode <= 'b0;
            rd <= 'b0;
            rs1 <= 'b0;
            rs2 <= 'b0;
            imm <= 'b0;
        end
        else if (STALL || MEM_WAIT) begin
            // do nothing
        end
        else begin
            pc <= PC;
            opcode <= OPCODE;
            rd <= RD;
            rs1 <= RS1;
            rs2 <= RS2;
            imm <= IMM;
        end
    end

    /* ----- デコード ----- */
    assign CHECK_ACCEPT = { 1'b0, imm[0] != 32'hffff_ffff };
    assign CHECK_PC     = pc;
    assign CHECK_OPCODE = opcode;
    assign CHECK_RD     = rd;
    assign CHECK_RS1    = rs1;
    assign CHECK_RS2    = rs2;
    assign CHECK_CSR    = imm[11:0];
    assign CHECK_IMM    = imm;

endmodule

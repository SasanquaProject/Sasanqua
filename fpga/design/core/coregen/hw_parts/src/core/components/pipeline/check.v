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
        input wire  [(32*PNUMS-1):0] RINST,

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
    reg [(32*PNUMS-1):0] pc, rinst;
    reg [(17*PNUMS-1):0] opcode;
    reg [( 5*PNUMS-1):0] rd, rs1, rs2;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            pc <= 'b0;
            opcode <= 'b0;
            rd <= 'b0;
            rs1 <= 'b0;
            rs2 <= 'b0;
            rinst <= { 32'b0, 32'h0000_0013 };
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
            rinst <= RINST;
        end
    end

    /* ----- デコード ----- */
    assign CHECK_PC     = pc;
    assign CHECK_OPCODE = opcode;
    assign CHECK_RD     = rd;
    assign CHECK_RS1    = rs1;
    assign CHECK_RS2    = rs2;

    genvar i;
    generate
        for (i = 0; i < PNUMS; i = i+1) begin
            assign CHECK_ACCEPT[i]                = CHECK_IMM[(32*(i+1)-1):(32*i)] != 32'hffff_ffff;
            assign CHECK_CSR[(12*(i+1)-1):(12*i)] = CHECK_IMM[(32*i+11):(32*i)];
            assign CHECK_IMM[(32*(i+1)-1):(32*i)] = decode_imm(rinst[(32*(i+1)-1):(32*i)]);
        end
    endgenerate

    function [31:0] decode_imm;
        input [31:0] INST;

        case (INST[6:0])
            // R形式
            7'b0110011: decode_imm = 32'b0;

            // I形式
            7'b1100111: decode_imm = { 20'b0, INST[31:20] };
            7'b0000011: decode_imm = { 20'b0, INST[31:20] };
            7'b0010011: decode_imm = { 20'b0, INST[31:20] };
            7'b0001111: decode_imm = { 20'b0, INST[31:20] };
            7'b1110011: decode_imm = { 20'b0, INST[31:20] };

            // S形式
            7'b0100011: decode_imm = { 20'b0, INST[31:25], INST[11:7] };

            // B形式
            7'b1100011: decode_imm = { 19'b0, INST[31], INST[7], INST[30:25], INST[11:8], 1'b0 };

            // U形式
            7'b0110111: decode_imm = { INST[31:12], 12'b0 };
            7'b0010111: decode_imm = { INST[31:12], 12'b0 };

            // J形式
            7'b1101111: decode_imm = { 11'b0, INST[31], INST[19:12], INST[20], INST[30:21], 1'b0 };

            default:    decode_imm = 32'hffff_ffff;
        endcase
    endfunction

endmodule

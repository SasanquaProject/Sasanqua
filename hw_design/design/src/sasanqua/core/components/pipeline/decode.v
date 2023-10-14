module decode
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          FLUSH,
        input wire          STALL,
        input wire          MEM_WAIT,

        /* ----- 前段との接続 ----- */
        input wire  [31:0]  PC,
        input wire  [31:0]  INST,

        /* ----- 後段との接続 ----- */
        output wire [31:0]  DECODE_PC,
        output wire [16:0]  DECODE_OPCODE,  // { opcode, funct3, funct7 }
        output wire [4:0]   DECODE_RD,
        output wire [4:0]   DECODE_RS1,
        output wire [4:0]   DECODE_RS2,
        output wire [31:0]  DECODE_IMM
    );

    /* ----- 入力取り込み ----- */
    reg [31:0] pc, inst;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            pc <= 32'b0;
            inst <= 32'h0000_0013;
        end
        else if (STALL || MEM_WAIT) begin
            // do nothing
        end
        else begin
            pc <= PC;
            inst <= INST;
        end
    end

    /* ---- デコード ----- */
    assign DECODE_PC       = pc;
    assign DECODE_OPCODE   = { inst[6:0], inst[14:12], inst[31:25] };
    assign DECODE_RD       = inst[11:7];
    assign DECODE_RS1      = inst[19:15];
    assign DECODE_RS2      = inst[24:20];
    assign DECODE_IMM      = decode_imm(inst);

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

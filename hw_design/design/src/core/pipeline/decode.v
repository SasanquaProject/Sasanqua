module decode
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          FLUSH,
        input wire          STALL,
        input wire          MEM_WAIT,

        /* ----- フェッチ部との接続 ----- */
        input wire  [31:0]  INST_PC,
        input wire  [31:0]  INST_DATA,

        /* ----- デコード部2との接続 ----- */
        output wire [31:0]  DECODE_PC,
        output wire [6:0]   DECODE_OPCODE,
        output wire [4:0]   DECODE_RD,
        output wire [4:0]   DECODE_RS1,
        output wire [4:0]   DECODE_RS2,
        output wire [2:0]   DECODE_FUNCT3,
        output wire [6:0]   DECODE_FUNCT7,
        output wire [31:0]  DECODE_IMM
    );

    /* ----- 入力取り込み ----- */
    reg [31:0]  inst_pc, inst_data;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            inst_pc <= 32'b0;
            inst_data <= 32'b0;
        end
        else if (STALL || MEM_WAIT) begin
            // do nothing
        end
        else begin
            inst_pc <= INST_PC;
            inst_data <= INST_DATA;
        end
    end

    /* ---- デコード ----- */
    assign DECODE_PC       = inst_pc;
    assign DECODE_OPCODE   = inst_data[6:0];
    assign DECODE_RD       = inst_data[11:7];
    assign DECODE_RS1      = inst_data[19:15];
    assign DECODE_RS2      = inst_data[24:20];
    assign DECODE_FUNCT3   = inst_data[14:12];
    assign DECODE_FUNCT7   = inst_data[31:25];
    assign DECODE_IMM      = decode_imm(inst_data);

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

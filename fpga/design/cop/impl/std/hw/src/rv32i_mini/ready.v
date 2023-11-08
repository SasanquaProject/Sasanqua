assign R_IMM = decode_imm(R_RINST);

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

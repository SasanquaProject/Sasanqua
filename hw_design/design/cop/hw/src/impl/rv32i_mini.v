module cop_rv32i_mini
    (
        /* ----- クロック・リセット ----- */
        input wire          CLK,
        input wire          RST,

        /* ----- Check 接続 ----- */
        input wire  [16:0]  C_OPCODE,
        output wire [31:0]  C_ACCEPT,

        /* ----- Ready 接続 ----- */
        input wire  [31:0]  R_INST,
        input wire  [4:0]   R_RD,
        input wire  [4:0]   R_RS1,
        input wire  [4:0]   R_RS2,
        input wire  [31:0]  R_IMM,

        /* ----- Exec 接続 ----- */
        input wire          E_ALLOW,
        input wire  [31:0]  E_PC,
        input wire  [31:0]  E_INST,
        input wire  [4:0]   E_RD,
        input wire  [4:0]   E_RS1,
        input wire  [31:0]  E_RS1_DATA,
        input wire  [4:0]   E_RS2,
        input wire  [31:0]  E_RS2_DATA,
        input wire  [31:0]  E_IMM,
        output wire         E_VALID,
        output reg          E_REG_W_EN,
        output reg  [4:0]   E_REG_W_RD,
        output reg  [31:0]  E_REG_W_DATA,
        output wire         E_EXC_EN,
        output wire [3:0]   E_EXC_CODE
    );

    /* ----- Check ----- */
    assign C_ACCEPT = check_inst(C_OPCODE);

    parameter INST_ADD      = 32'd1;
    parameter INST_ADDI     = 32'd2;
    parameter INST_SUB      = 32'd3;
    parameter INST_AND      = 32'd4;
    parameter INST_ANDI     = 32'd5;
    parameter INST_OR       = 32'd6;
    parameter INST_ORI      = 32'd7;
    parameter INST_XOR      = 32'd8;
    parameter INST_XORI     = 32'd9;
    parameter INST_SLL      = 32'd10;
    parameter INST_SLLI     = 32'd11;
    parameter INST_SRA      = 32'd12;
    parameter INST_SRAI     = 32'd13;
    parameter INST_SRL      = 32'd14;
    parameter INST_SRLI     = 32'd15;
    parameter INST_LUI      = 32'd16;
    parameter INST_AUIPC    = 32'd17;
    parameter INST_SLT      = 32'd18;
    parameter INST_SLTU     = 32'd19;
    parameter INST_SLTI     = 32'd20;
    parameter INST_SLTIU    = 32'd21;

    function [31:0] check_inst;
        input [16:0] OPCODE;
        casez (OPCODE)
            17'b0110011_000_0000000: check_inst = INST_ADD;
            17'b0010011_000_zzzzzzz: check_inst = INST_ADDI;
            17'b0110011_000_0100000: check_inst = INST_SUB;
            17'b0110011_111_0000000: check_inst = INST_AND;
            17'b0010011_111_zzzzzzz: check_inst = INST_ANDI;
            17'b0110011_110_0000000: check_inst = INST_OR;
            17'b0010011_110_zzzzzzz: check_inst = INST_ORI;
            17'b0110011_100_0000000: check_inst = INST_XOR;
            17'b0010011_100_zzzzzzz: check_inst = INST_XORI;
            17'b0110011_001_0000000: check_inst = INST_SLL;
            17'b0010011_001_0000000: check_inst = INST_SLLI;
            17'b0110011_101_0100000: check_inst = INST_SRA;
            17'b0010011_101_0100000: check_inst = INST_SRAI;
            17'b0110011_101_0000000: check_inst = INST_SRL;
            17'b0010011_101_0000000: check_inst = INST_SRLI;
            17'b0110111_zzz_zzzzzzz: check_inst = INST_LUI;
            17'b0010111_zzz_zzzzzzz: check_inst = INST_AUIPC;
            17'b0110011_010_0000000: check_inst = INST_SLT;
            17'b0110011_011_0000000: check_inst = INST_SLTU;
            17'b0010011_010_zzzzzzz: check_inst = INST_SLTI;
            17'b0010011_011_zzzzzzz: check_inst = INST_SLTIU;
            default:                 check_inst = 32'b0;
        endcase
    endfunction

    /* ----- Ready ----- */
    // ...

    /* ----- Exec ----- */
    wire signed [31:0] E_RS1_DATA_S = E_RS1_DATA;
    wire signed [31:0] E_RS2_DATA_S = E_RS2_DATA;

    assign E_VALID      = E_ALLOW;
    assign E_EXC_EN     = 1'b0;
    assign E_EXC_CODE   = 4'b0;

    always @* begin
        casez (E_INST)
            INST_ADD: begin
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA + E_RS2_DATA;
            end
            INST_ADDI: begin
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA + { { 20{ E_IMM[11] } }, E_IMM[11:0] };
            end
            INST_SUB: begin
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA - E_RS2_DATA;
            end
            INST_AND: begin
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA & E_RS2_DATA;
            end
            INST_ANDI: begin
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA & { { 20{ E_IMM[11] } }, E_IMM[11:0] };
            end
            INST_OR: begin
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA | E_RS2_DATA;
            end
            INST_ORI: begin
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA | { { 20{ E_IMM[11] } }, E_IMM[11:0] };
            end
            INST_XOR: begin
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA ^ E_RS2_DATA;
            end
            INST_XORI: begin
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA ^ { { 20{ E_IMM[11] } }, E_IMM[11:0] };
            end
            INST_SLL: begin
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA << (E_RS2_DATA[4:0]);
            end
            INST_SLLI: begin
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA << (E_IMM[4:0]);
            end
            INST_SRA: begin
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA_S >>> (E_RS2_DATA[4:0]);
            end
            INST_SRAI: begin
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA_S >>> (E_IMM[4:0]);
            end
            INST_SRL: begin
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA >> (E_RS2_DATA[4:0]);
            end
            INST_SRLI: begin
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA >> (E_IMM[4:0]);
            end
            INST_LUI: begin
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= (E_IMM[31:12]) << 12;
            end
            INST_AUIPC: begin
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_PC + ((E_IMM[31:12]) << 12);
            end
            INST_SLT: begin
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA_S < E_RS2_DATA_S ? 32'b1 : 32'b0;
            end
            INST_SLTU: begin
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA < E_RS2_DATA ? 32'b1 : 32'b0;
            end
            INST_SLTI: begin
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA_S < $signed({ { 20{ E_IMM[11] } }, E_IMM[11:0] }) ? 32'b1 : 32'b0;
            end
            INST_SLTIU: begin
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA < { { 20{ E_IMM[11] } }, E_IMM[11:0] } ? 32'b1 : 32'b0;
            end
            default: begin
                E_REG_W_EN <= 1'b0;
                E_REG_W_RD <= 5'b0;
                E_REG_W_DATA <= 32'b0;
            end
        endcase
    end

endmodule

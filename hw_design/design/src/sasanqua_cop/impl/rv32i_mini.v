module cop_rv32i_mini
    (
        /* ----- クロック・リセット ----- */
        input wire          CLK,
        input wire          RST,

        /* ----- Check 接続 ----- */
        input wire  [16:0]  C_OPCODE,
        output wire         C_ACCEPT,

        /* ----- Ready 接続 ----- */
        input wire  [16:0]  R_OPCODE,
        input wire  [4:0]   R_RD,
        input wire  [4:0]   R_RS1,
        input wire  [4:0]   R_RS2,
        input wire  [31:0]  R_IMM,

        /* ----- Exec 接続 ----- */
        input wire          E_ALLOW,
        input wire  [31:0]  E_PC,
        input wire  [16:0]  E_OPCODE,
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
    assign C_ACCEPT = check_inst(C_OPCODE) != 5'b0;

    parameter INST_ADD      = 5'd1;
    parameter INST_ADDI     = 5'd2;
    parameter INST_SUB      = 5'd3;
    parameter INST_AND      = 5'd4;
    parameter INST_ANDI     = 5'd5;
    parameter INST_OR       = 5'd6;
    parameter INST_ORI      = 5'd7;
    parameter INST_XOR      = 5'd8;
    parameter INST_XORI     = 5'd9;
    parameter INST_SLL      = 5'd10;
    parameter INST_SLLI     = 5'd11;
    parameter INST_SRA      = 5'd12;
    parameter INST_SRAI     = 5'd13;
    parameter INST_SRL      = 5'd14;
    parameter INST_SRLI     = 5'd15;
    parameter INST_LUI      = 5'd16;
    parameter INST_AUIPC    = 5'd17;
    parameter INST_SLT      = 5'd18;
    parameter INST_SLTU     = 5'd19;
    parameter INST_SLTI     = 5'd20;
    parameter INST_SLTIU    = 5'd21;

    function [4:0] check_inst;
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
            default:                 check_inst = 5'b0;
        endcase
    endfunction

    /* ----- Ready ----- */
    reg [4:0] r_inst_kind;

    always @ (posedge CLK) begin
        r_inst_kind <= check_inst(C_OPCODE);
    end

    /* ----- Exec ----- */
    reg [4:0] e_inst_kind;

    always @ (posedge CLK) begin
        e_inst_kind <= r_inst_kind;
    end

    wire signed [31:0] E_RS1_DATA_S = E_RS1_DATA;
    wire signed [31:0] E_RS2_DATA_S = E_RS2_DATA;

    assign E_VALID      = E_ALLOW ? e_inst_kind != 5'b0 : 1'b0;
    assign E_EXC_EN     = 1'b0;
    assign E_EXC_CODE   = 4'b0;

    always @* begin
        casez (e_inst_kind)
            INST_ADD: begin  // add
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA + E_RS2_DATA;
            end
            INST_ADDI: begin  // addi
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA + { { 20{ E_IMM[11] } }, E_IMM[11:0] };
            end
            INST_SUB: begin  // sub
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA - E_RS2_DATA;
            end
            INST_AND: begin  // and
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA & E_RS2_DATA;
            end
            INST_ANDI: begin  // andi
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA & { { 20{ E_IMM[11] } }, E_IMM[11:0] };
            end
            INST_OR: begin  // or
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA | E_RS2_DATA;
            end
            INST_ORI: begin  // ori
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA | { { 20{ E_IMM[11] } }, E_IMM[11:0] };
            end
            INST_XOR: begin  // xor
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA ^ E_RS2_DATA;
            end
            INST_XORI: begin  // xori
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA ^ { { 20{ E_IMM[11] } }, E_IMM[11:0] };
            end
            INST_SLL: begin  // sll
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA << (E_RS2_DATA[4:0]);
            end
            INST_SLLI: begin  // slli
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA << (E_IMM[4:0]);
            end
            INST_SRA: begin  // sra
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA_S >>> (E_RS2_DATA[4:0]);
            end
            INST_SRAI: begin  // srai
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA_S >>> (E_IMM[4:0]);
            end
            INST_SRL: begin  // srl
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA >> (E_RS2_DATA[4:0]);
            end
            INST_SRLI: begin  // srli
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA >> (E_IMM[4:0]);
            end
            INST_LUI: begin  // lui
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= (E_IMM[31:12]) << 12;
            end
            INST_AUIPC: begin  // auipc
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_PC + ((E_IMM[31:12]) << 12);
            end
            INST_SLT: begin  // slt
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA_S < E_RS2_DATA_S ? 32'b1 : 32'b0;
            end
            INST_SLTU: begin  // sltu
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA < E_RS2_DATA ? 32'b1 : 32'b0;
            end
            INST_SLTI: begin  // slti
                E_REG_W_EN <= 1'b1;
                E_REG_W_RD <= E_RD;
                E_REG_W_DATA <= E_RS1_DATA_S < $signed({ { 20{ E_IMM[11] } }, E_IMM[11:0] }) ? 32'b1 : 32'b0;
            end
            INST_SLTIU: begin  // sltiu
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

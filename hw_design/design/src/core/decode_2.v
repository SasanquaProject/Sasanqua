module decode_2
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,

        /* ----- デコード部2との接続 ----- */
        input wire          DECODE1_VALID,
        input wire [31:0]   DECODE1_PC,
        input wire [6:0]    DECODE1_OPCODE,
        input wire [4:0]    DECODE1_RD,
        input wire [2:0]    DECODE1_FUNCT3,
        input wire [6:0]    DECODE1_FUNCT7,
        input wire [31:0]   DECODE1_IMM_I,
        input wire [31:0]   DECODE1_IMM_S,
        input wire [31:0]   DECODE1_IMM_B,
        input wire [31:0]   DECODE1_IMM_U,
        input wire [31:0]   DECODE1_IMM_J,

        /* ----- 実行部との接続 ----- */
        output reg          DECODE2_VALID,
        output wire [31:0]  DECODE2_PC,
        output wire [6:0]   DECODE2_OPCODE,
        output wire [4:0]   DECODE2_RD,
        output wire [2:0]   DECODE2_FUNCT3,
        output wire [6:0]   DECODE2_FUNCT7,
        output reg [31:0]   DECODE2_IMM
    );

    /* ----- 入力取り込み ----- */
    reg         decode1_valid;
    reg  [31:0] decode1_pc, decode1_imm_i, decode1_imm_s, decode1_imm_b, decode1_imm_u, decode1_imm_j;
    reg  [6:0]  decode1_opcode, decode1_funct7;
    reg  [4:0]  decode1_rd;
    reg  [2:0]  decode1_funct3;

    always @ (posedge CLK) begin
        decode1_valid <= DECODE1_VALID;
        decode1_pc <= DECODE1_PC;
        decode1_opcode <= DECODE1_OPCODE;
        decode1_rd <= DECODE1_RD;
        decode1_funct3 <= DECODE1_FUNCT3;
        decode1_funct7 <= DECODE1_FUNCT7;
        decode1_imm_i <= DECODE1_IMM_I;
        decode1_imm_s <= DECODE1_IMM_S;
        decode1_imm_b <= DECODE1_IMM_B;
        decode1_imm_u <= DECODE1_IMM_U;
        decode1_imm_j <= DECODE1_IMM_J;
    end

    /* ----- デコード ----- */
    assign DECODE2_PC       = decode1_pc;
    assign DECODE2_OPCODE   = decode1_opcode;
    assign DECODE2_RD       = decode1_rd;
    assign DECODE2_FUNCT3   = decode1_funct3;
    assign DECODE2_FUNCT7   = decode1_funct7;

    always @* begin
        // R形式
        if (
            decode1_opcode == 7'b0110011
        ) begin
            DECODE2_VALID <= decode1_valid;
            DECODE2_IMM <= 32'b0;
        end

        // I形式
        if (
            decode1_opcode == 7'b1100111 ||
            decode1_opcode == 7'b0000011 ||
            decode1_opcode == 7'b0010011 ||
            decode1_opcode == 7'b0001111 ||
            decode1_opcode == 7'b1110011
        ) begin
            DECODE2_VALID <= decode1_valid;
            DECODE2_IMM <= decode1_imm_i;
        end

        // S形式
        else if (
            decode1_opcode == 7'b0100011
        ) begin
            DECODE2_VALID <= decode1_valid;
            DECODE2_IMM <= decode1_imm_s;
        end

        // B形式
        else if (
            decode1_opcode == 7'b1100011
        ) begin
            DECODE2_VALID <= decode1_valid;
            DECODE2_IMM <= decode1_imm_b;
        end

        // U形式
        else if (
            decode1_opcode == 7'b0110111 ||
            decode1_opcode == 7'b0010111
        ) begin
            DECODE2_VALID <= decode1_valid;
            DECODE2_IMM <= decode1_imm_u;
        end

        // J形式
        else if (
            decode1_opcode == 7'b1101111
        ) begin
            DECODE2_VALID <= decode1_valid;
            DECODE2_IMM <= decode1_imm_j;
        end

        // 未対応命令
        else begin
            DECODE2_VALID <= 1'b0;
            DECODE2_IMM <= 32'b0;
        end
    end

endmodule

module decode_2nd
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          STALL,

        /* ----- デコード部2との接続 ----- */
        input wire          DECODE_1ST_VALID,
        input wire [31:0]   DECODE_1ST_PC,
        input wire [6:0]    DECODE_1ST_OPCODE,
        input wire [4:0]    DECODE_1ST_RD,
        input wire [4:0]    DECODE_1ST_RS1,
        input wire [4:0]    DECODE_1ST_RS2,
        input wire [2:0]    DECODE_1ST_FUNCT3,
        input wire [6:0]    DECODE_1ST_FUNCT7,
        input wire [31:0]   DECODE_1ST_IMM_I,
        input wire [31:0]   DECODE_1ST_IMM_S,
        input wire [31:0]   DECODE_1ST_IMM_B,
        input wire [31:0]   DECODE_1ST_IMM_U,
        input wire [31:0]   DECODE_1ST_IMM_J,

        /* ----- スケジューラ1との接続 ----- */
        output reg          DECODE_2ND_VALID,
        output wire [31:0]  DECODE_2ND_PC,
        output wire [6:0]   DECODE_2ND_OPCODE,
        output wire [4:0]   DECODE_2ND_RD,
        output wire [4:0]   DECODE_2ND_RS1,
        output wire [4:0]   DECODE_2ND_RS2,
        output wire [2:0]   DECODE_2ND_FUNCT3,
        output wire [6:0]   DECODE_2ND_FUNCT7,
        output reg  [31:0]  DECODE_2ND_IMM
    );

    /* ----- 入力取り込み ----- */
    reg         decode_1st_valid;
    reg  [31:0] decode_1st_pc, decode_1st_imm_i, decode_1st_imm_s, decode_1st_imm_b, decode_1st_imm_u, decode_1st_imm_j;
    reg  [6:0]  decode_1st_opcode, decode_1st_funct7;
    reg  [4:0]  decode_1st_rd, decode_1st_rs1, decode_1st_rs2;
    reg  [2:0]  decode_1st_funct3;

    always @ (posedge CLK) begin
        if (RST) begin
            decode_1st_valid <= 1'b0;
            decode_1st_pc <= 32'b0;
            decode_1st_opcode <= 7'b0;
            decode_1st_rd <= 5'b0;
            decode_1st_rs1 <= 5'b0;
            decode_1st_rs2 <= 5'b0;
            decode_1st_funct3 <= 3'b0;
            decode_1st_funct7 <= 7'b0;
            decode_1st_imm_i <= 32'b0;
            decode_1st_imm_s <= 32'b0;
            decode_1st_imm_b <= 32'b0;
            decode_1st_imm_u <= 32'b0;
            decode_1st_imm_j <= 32'b0;
        end
        else if (STALL) begin
            // do nothing
        end
        else begin
            decode_1st_valid <= DECODE_1ST_VALID;
            decode_1st_pc <= DECODE_1ST_PC;
            decode_1st_opcode <= DECODE_1ST_OPCODE;
            decode_1st_rd <= DECODE_1ST_RD;
            decode_1st_rs1 <= DECODE_1ST_RS1;
            decode_1st_rs2 <= DECODE_1ST_RS2;
            decode_1st_funct3 <= DECODE_1ST_FUNCT3;
            decode_1st_funct7 <= DECODE_1ST_FUNCT7;
            decode_1st_imm_i <= DECODE_1ST_IMM_I;
            decode_1st_imm_s <= DECODE_1ST_IMM_S;
            decode_1st_imm_b <= DECODE_1ST_IMM_B;
            decode_1st_imm_u <= DECODE_1ST_IMM_U;
            decode_1st_imm_j <= DECODE_1ST_IMM_J;
        end
    end

    /* ----- デコード ----- */
    assign DECODE_2ND_PC       = decode_1st_pc;
    assign DECODE_2ND_OPCODE   = decode_1st_opcode;
    assign DECODE_2ND_RD       = decode_1st_rd;
    assign DECODE_2ND_RS1      = decode_1st_rs1;
    assign DECODE_2ND_RS2      = decode_1st_rs2;
    assign DECODE_2ND_FUNCT3   = decode_1st_funct3;
    assign DECODE_2ND_FUNCT7   = decode_1st_funct7;

    always @* begin
        // R形式
        if (
            decode_1st_opcode == 7'b0110011
        ) begin
            DECODE_2ND_VALID <= decode_1st_valid;
            DECODE_2ND_IMM <= 32'b0;
        end

        // I形式
        if (
            decode_1st_opcode == 7'b1100111 ||
            decode_1st_opcode == 7'b0000011 ||
            decode_1st_opcode == 7'b0010011 ||
            decode_1st_opcode == 7'b0001111 ||
            decode_1st_opcode == 7'b1110011
        ) begin
            DECODE_2ND_VALID <= decode_1st_valid;
            DECODE_2ND_IMM <= decode_1st_imm_i;
        end

        // S形式
        else if (
            decode_1st_opcode == 7'b0100011
        ) begin
            DECODE_2ND_VALID <= decode_1st_valid;
            DECODE_2ND_IMM <= decode_1st_imm_s;
        end

        // B形式
        else if (
            decode_1st_opcode == 7'b1100011
        ) begin
            DECODE_2ND_VALID <= decode_1st_valid;
            DECODE_2ND_IMM <= decode_1st_imm_b;
        end

        // U形式
        else if (
            decode_1st_opcode == 7'b0110111 ||
            decode_1st_opcode == 7'b0010111
        ) begin
            DECODE_2ND_VALID <= decode_1st_valid;
            DECODE_2ND_IMM <= decode_1st_imm_u;
        end

        // J形式
        else if (
            decode_1st_opcode == 7'b1101111
        ) begin
            DECODE_2ND_VALID <= decode_1st_valid;
            DECODE_2ND_IMM <= decode_1st_imm_j;
        end

        // 未対応命令
        else begin
            DECODE_2ND_VALID <= 1'b0;
            DECODE_2ND_IMM <= 32'b0;
        end
    end

endmodule

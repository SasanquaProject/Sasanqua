module cushion
    (
        /* ----- 制御 ----- */
        // クロック・リセット
        input wire          CLK,
        input wire          RST,

        // パイプライン
        input wire          FLUSH,
        input wire          MEM_WAIT,

        /* ----- 前段との接続 ----- */
        // A (main stream)
        input wire          A_ALLOW,
        input wire          A_VALID,
        input wire  [31:0]  A_PC,
        input wire          A_REG_W_EN,
        input wire  [4:0]   A_REG_W_RD,
        input wire  [31:0]  A_REG_W_DATA,
        input wire          A_CSR_W_EN,
        input wire  [11:0]  A_CSR_W_ADDR,
        input wire  [31:0]  A_CSR_W_DATA,
        input wire          A_MEM_R_EN,
        input wire  [4:0]   A_MEM_R_RD,
        input wire  [31:0]  A_MEM_R_ADDR,
        input wire  [3:0]   A_MEM_R_STRB,
        input wire          A_MEM_R_SIGNED,
        input wire          A_MEM_W_EN,
        input wire  [31:0]  A_MEM_W_ADDR,
        input wire  [3:0]   A_MEM_W_STRB,
        input wire  [31:0]  A_MEM_W_DATA,
        input wire          A_JMP_DO,
        input wire  [31:0]  A_JMP_PC,
        input wire          A_EXC_EN,
        input wire  [3:0]   A_EXC_CODE,

        // B (cop)
        input wire          B_ALLOW,
        input wire          B_VALID,
        input wire  [31:0]  B_PC,
        input wire          B_REG_W_EN,
        input wire  [4:0]   B_REG_W_RD,
        input wire  [31:0]  B_REG_W_DATA,
        input wire          B_EXC_EN,
        input wire  [3:0]   B_EXC_CODE,

        /* ----- 後段との接続 ----- */
        output wire         CUSHION_VALID,
        output wire [31:0]  CUSHION_PC,
        output wire         CUSHION_REG_W_EN,
        output wire [4:0]   CUSHION_REG_W_RD,
        output wire [31:0]  CUSHION_REG_W_DATA,
        output wire         CUSHION_CSR_W_EN,
        output wire [11:0]  CUSHION_CSR_W_ADDR,
        output wire [31:0]  CUSHION_CSR_W_DATA,
        output wire         CUSHION_MEM_R_EN,
        output wire [4:0]   CUSHION_MEM_R_RD,
        output wire [31:0]  CUSHION_MEM_R_ADDR,
        output wire [3:0]   CUSHION_MEM_R_STRB,
        output wire         CUSHION_MEM_R_SIGNED,
        output wire         CUSHION_MEM_W_EN,
        output wire [31:0]  CUSHION_MEM_W_ADDR,
        output wire [3:0]   CUSHION_MEM_W_STRB,
        output wire [31:0]  CUSHION_MEM_W_DATA,
        output wire         CUSHION_JMP_DO,
        output wire [31:0]  CUSHION_JMP_PC,
        output wire         CUSHION_EXC_EN,
        output wire [3:0]   CUSHION_EXC_CODE,
        output wire [31:0]  CUSHION_EXC_PC
    );

    /* ----- 入力取り込み ----- */
    // A (main stream)
    reg         a_allow, a_valid, a_reg_w_en, a_csr_w_en, a_mem_r_en, a_mem_r_signed, a_mem_w_en, a_jmp_do, a_exc_en;
    reg [31:0]  a_pc, a_reg_w_data, a_csr_w_data, a_mem_r_addr, a_mem_w_addr, a_mem_w_data, a_jmp_pc;
    reg [11:0]  a_csr_w_addr;
    reg [4:0]   a_reg_w_rd, a_mem_r_rd;
    reg [3:0]   a_mem_r_strb, a_mem_w_strb, a_exc_code;

    // B (cop)
    reg         b_allow, b_valid, b_reg_w_en, b_exc_en;
    reg [31:0]  b_pc, b_reg_w_data;
    reg [4:0]   b_reg_w_rd;
    reg [3:0]   b_exc_code;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            a_allow <= 1'b0;
            a_valid <= 1'b0;
            a_pc <= 32'b0;
            a_reg_w_en <= 1'b0;
            a_reg_w_rd <= 5'b0;
            a_reg_w_data <= 32'b0;
            a_csr_w_en <= 1'b0;
            a_csr_w_addr <= 12'b0;
            a_csr_w_data <= 32'b0;
            a_mem_r_en <= 1'b0;
            a_mem_r_rd <= 5'b0;
            a_mem_r_addr <= 32'b0;
            a_mem_r_strb <= 4'b0;
            a_mem_r_signed <= 1'b0;
            a_mem_w_en <= 1'b0;
            a_mem_w_addr <= 32'b0;
            a_mem_w_strb <= 4'b0;
            a_mem_w_data <= 32'b0;
            a_jmp_do <= 1'b0;
            a_jmp_pc <= 32'b0;
            a_exc_en <= 1'b0;
            a_exc_code <= 4'b0;
            b_allow <= 1'b0;
            b_valid <= 1'b0;
            b_pc <= 32'b0;
            b_reg_w_en <= 1'b0;
            b_reg_w_rd <= 5'b0;
            b_reg_w_data <= 32'b0;
            b_exc_en <= 1'b0;
            b_exc_code <= 4'b0;
        end
        else if (MEM_WAIT) begin
            // do nothing
        end
        else begin
            a_allow <= A_ALLOW;
            a_valid <= A_VALID;
            a_pc <= A_PC;
            a_reg_w_en <= A_REG_W_EN;
            a_reg_w_rd <= A_REG_W_RD;
            a_reg_w_data <= A_REG_W_DATA;
            a_csr_w_en <= A_CSR_W_EN;
            a_csr_w_addr <= A_CSR_W_ADDR;
            a_csr_w_data <= A_CSR_W_DATA;
            a_mem_r_en <= A_MEM_R_EN;
            a_mem_r_rd <= A_MEM_R_RD;
            a_mem_r_addr <= A_MEM_R_ADDR;
            a_mem_r_strb <= A_MEM_R_STRB;
            a_mem_r_signed <= A_MEM_R_SIGNED;
            a_mem_w_en <= A_MEM_W_EN;
            a_mem_w_addr <= A_MEM_W_ADDR;
            a_mem_w_strb <= A_MEM_W_STRB;
            a_mem_w_data <= A_MEM_W_DATA;
            a_jmp_do <= A_JMP_DO;
            a_jmp_pc <= A_JMP_PC;
            a_exc_en <= A_EXC_EN;
            a_exc_code <= A_EXC_CODE;
            b_allow <= B_ALLOW;
            b_valid <= B_VALID;
            b_pc <= B_PC;
            b_reg_w_en <= B_REG_W_EN;
            b_reg_w_rd <= B_REG_W_RD;
            b_reg_w_data <= B_REG_W_DATA;
            b_exc_en <= B_EXC_EN;
            b_exc_code <= B_EXC_CODE;
        end
    end

    /* ----- 出力 ----- */
    wire a_ok = !a_allow || a_valid;
    wire b_ok = !b_allow || b_valid;
    wire ok   = a_ok && b_ok;

    wire [31:0] merge_pc         = a_ok ? a_pc :
                                  (b_ok ? b_pc : 32'b0);
    wire        merge_reg_w_en   = a_ok ? a_reg_w_en :
                                  (b_ok ? b_reg_w_en : 1'b0);
    wire [4:0]  merge_reg_w_rd   = a_ok ? a_reg_w_rd :
                                  (b_ok ? b_reg_w_rd : 5'b0);
    wire [31:0] merge_reg_w_data = a_ok ? a_reg_w_data :
                                  (b_ok ? b_reg_w_data : 32'b0);
    wire        merge_exc_en     = a_ok ? a_exc_en :
                                  (b_ok ? b_exc_en : 1'b0);
    wire [4:0]  merge_exc_code   = a_ok ? a_exc_code :
                                  (b_ok ? b_exc_code : 5'b0);

    assign CUSHION_VALID         = ok;
    assign CUSHION_PC            = ok ? merge_pc : 32'b0;
    assign CUSHION_REG_W_EN      = ok ? merge_reg_w_en : 1'b0;
    assign CUSHION_REG_W_RD      = ok ? merge_reg_w_rd : 5'b0;
    assign CUSHION_REG_W_DATA    = ok ? merge_reg_w_data : 32'b0;
    assign CUSHION_CSR_W_EN      = ok ? a_csr_w_en : 1'b0;
    assign CUSHION_CSR_W_ADDR    = ok ? a_csr_w_addr : 12'b0;
    assign CUSHION_CSR_W_DATA    = ok ? a_csr_w_data : 32'b0;
    assign CUSHION_MEM_R_EN      = ok ? a_mem_r_en : 1'b0;
    assign CUSHION_MEM_R_RD      = ok ? a_mem_r_rd : 5'b0;
    assign CUSHION_MEM_R_ADDR    = ok ? a_mem_r_addr : 32'b0;
    assign CUSHION_MEM_R_STRB    = ok ? a_mem_r_strb : 4'b0;
    assign CUSHION_MEM_R_SIGNED  = ok ? a_mem_r_signed : 1'b0;
    assign CUSHION_MEM_W_EN      = ok ? a_mem_w_en : 1'b0;
    assign CUSHION_MEM_W_ADDR    = ok ? a_mem_w_addr : 32'b0;
    assign CUSHION_MEM_W_STRB    = ok ? a_mem_w_strb : 4'b0;
    assign CUSHION_MEM_W_DATA    = ok ? a_mem_w_data : 32'b0;
    assign CUSHION_JMP_DO        = ok ? a_jmp_do : 1'b0;
    assign CUSHION_JMP_PC        = ok ? a_jmp_pc : 32'b0;
    assign CUSHION_EXC_EN        = ok ? merge_exc_en : 1'b0;
    assign CUSHION_EXC_CODE      = ok ? merge_exc_code : 4'b0;

endmodule

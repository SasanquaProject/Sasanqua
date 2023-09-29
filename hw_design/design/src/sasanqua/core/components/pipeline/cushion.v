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
        input wire  [31:0]  B_PC,
        input wire          B_REG_W_EN,
        input wire  [4:0]   B_REG_W_RD,
        input wire  [31:0]  B_REG_W_DATA,
        input wire          B_EXC_EN,
        input wire  [3:0]   B_EXC_CODE,

        /* ----- 後段との接続 ----- */
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
    reg         a_reg_w_en, a_csr_w_en, a_mem_r_en, a_mem_r_signed, a_mem_w_en, a_jmp_do, a_exc_en;
    reg [31:0]  a_pc, a_reg_w_data, a_csr_w_data, a_mem_r_addr, a_mem_w_addr, a_mem_w_data, a_jmp_pc;
    reg [11:0]  a_csr_w_addr;
    reg [4:0]   a_reg_w_rd, a_mem_r_rd;
    reg [3:0]   a_mem_r_strb, a_mem_w_strb, a_exc_code;

    // B (cop)
    reg         b_reg_w_en, b_exc_en;
    reg [31:0]  b_pc, b_reg_w_data;
    reg [4:0]   b_reg_w_rd;
    reg [3:0]   b_exc_code;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
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
            b_pc <= B_PC;
            b_reg_w_en <= B_REG_W_EN;
            b_reg_w_rd <= B_REG_W_RD;
            b_reg_w_data <= B_REG_W_DATA;
            b_exc_en <= B_EXC_EN;
            b_exc_code <= B_EXC_CODE;
        end
    end

    /* ----- 出力 ----- */
    assign CUSHION_PC           = a_pc;
    assign CUSHION_REG_W_EN     = a_reg_w_en;
    assign CUSHION_REG_W_RD     = a_reg_w_rd;
    assign CUSHION_REG_W_DATA   = a_reg_w_data;
    assign CUSHION_CSR_W_EN     = a_csr_w_en;
    assign CUSHION_CSR_W_ADDR   = a_csr_w_addr;
    assign CUSHION_CSR_W_DATA   = a_csr_w_data;
    assign CUSHION_MEM_R_EN     = a_mem_r_en;
    assign CUSHION_MEM_R_RD     = a_mem_r_rd;
    assign CUSHION_MEM_R_ADDR   = a_mem_r_addr;
    assign CUSHION_MEM_R_STRB   = a_mem_r_strb;
    assign CUSHION_MEM_R_SIGNED = a_mem_r_signed;
    assign CUSHION_MEM_W_EN     = a_mem_w_en;
    assign CUSHION_MEM_W_ADDR   = a_mem_w_addr;
    assign CUSHION_MEM_W_STRB   = a_mem_w_strb;
    assign CUSHION_MEM_W_DATA   = a_mem_w_data;
    assign CUSHION_JMP_DO       = a_jmp_do;
    assign CUSHION_JMP_PC       = a_jmp_pc;
    assign CUSHION_EXC_EN       = a_exc_en;
    assign CUSHION_EXC_CODE     = a_exc_code;

endmodule

module cushion
    (
        /* ----- 制御 ----- */
        // クロック・リセット
        input wire          CLK,
        input wire          RST,

        // パイプライン
        input wire          FLUSH,
        input wire          MEM_WAIT,

        // CSRに基づく制御信号
        input wire [1:0]    TRAP_VEC_MODE,
        input wire [31:0]   TRAP_VEC_BASE,

        /* ----- 実行部との接続 ----- */
        // レジスタ(rv32i:W)
        input wire          EXEC_REG_W_EN,
        input wire  [4:0]   EXEC_REG_W_RD,
        input wire  [31:0]  EXEC_REG_W_DATA,

        // レジスタ(csrs:W)
        input wire          EXEC_CSR_W_EN,
        input wire  [11:0]  EXEC_CSR_W_ADDR,
        input wire  [31:0]  EXEC_CSR_W_DATA,

        // メモリ(R)
        input wire          EXEC_MEM_R_EN,
        input wire  [4:0]   EXEC_MEM_R_RD,
        input wire  [31:0]  EXEC_MEM_R_ADDR,
        input wire  [3:0]   EXEC_MEM_R_STRB,
        input wire          EXEC_MEM_R_SIGNED,

        // メモリ(W)
        input wire          EXEC_MEM_W_EN,
        input wire  [31:0]  EXEC_MEM_W_ADDR,
        input wire  [3:0]   EXEC_MEM_W_STRB,
        input wire  [31:0]  EXEC_MEM_W_DATA,

        // PC更新
        input wire          EXEC_JMP_DO,
        input wire  [31:0]  EXEC_JMP_PC,

        // 例外
        input wire          EXEC_EXC_EN,
        input wire  [3:0]   EXEC_EXC_CODE,
        input wire  [31:0]  EXEC_EXC_PC,

        /* ----- メモリアクセス(r)部との接続 ----- */
        // レジスタ(rv32i:W)
        output wire         CUSHION_REG_W_EN,
        output wire [4:0]   CUSHION_REG_W_RD,
        output wire [31:0]  CUSHION_REG_W_DATA,

        // レジスタ(csrs:W)
        output wire         CUSHION_CSR_W_EN,
        output wire [11:0]  CUSHION_CSR_W_ADDR,
        output wire [31:0]  CUSHION_CSR_W_DATA,

        // メモリ(R)
        output wire         CUSHION_MEM_R_EN,
        output wire [4:0]   CUSHION_MEM_R_RD,
        output wire [31:0]  CUSHION_MEM_R_ADDR,
        output wire [3:0]   CUSHION_MEM_R_STRB,
        output wire         CUSHION_MEM_R_SIGNED,

        // メモリ(W)
        output wire         CUSHION_MEM_W_EN,
        output wire [31:0]  CUSHION_MEM_W_ADDR,
        output wire [3:0]   CUSHION_MEM_W_STRB,
        output wire [31:0]  CUSHION_MEM_W_DATA,

        // PC更新
        output wire         CUSHION_JMP_DO,
        output wire [31:0]  CUSHION_JMP_PC,

        // 例外
        output wire         CUSHION_EXC_EN,
        output wire [3:0]   CUSHION_EXC_CODE,
        output wire [31:0]  CUSHION_EXC_PC
    );

    /* ----- 入力取り込み ----- */
    reg [1:0]  trap_vec_mode;
    reg [31:0] trap_vec_base;

    reg         exec_reg_w_en, exec_csr_w_en, exec_mem_r_en, exec_mem_r_signed, exec_mem_w_en, exec_jmp_do, exec_exc_en;
    reg [31:0]  exec_reg_w_data, exec_csr_w_data, exec_mem_r_addr, exec_mem_w_addr, exec_mem_w_data, exec_jmp_pc, exec_exc_pc;
    reg [11:0]  exec_csr_w_addr;
    reg [4:0]   exec_reg_w_rd, exec_mem_r_rd;
    reg [3:0]   exec_mem_r_strb, exec_mem_w_strb, exec_exc_code;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            trap_vec_mode <= 2'b0;
            trap_vec_base <= 32'b0;
            exec_reg_w_en <= 1'b0;
            exec_reg_w_rd <= 5'b0;
            exec_reg_w_data <= 32'b0;
            exec_csr_w_en <= 1'b0;
            exec_csr_w_addr <= 12'b0;
            exec_csr_w_data <= 32'b0;
            exec_mem_r_en <= 1'b0;
            exec_mem_r_rd <= 5'b0;
            exec_mem_r_addr <= 32'b0;
            exec_mem_r_strb <= 4'b0;
            exec_mem_r_signed <= 1'b0;
            exec_mem_w_en <= 1'b0;
            exec_mem_w_addr <= 32'b0;
            exec_mem_w_strb <= 4'b0;
            exec_mem_w_data <= 32'b0;
            exec_jmp_do <= 1'b0;
            exec_jmp_pc <= 32'b0;
            exec_exc_en <= 1'b0;
            exec_exc_code <= 4'b0;
            exec_exc_pc <= 32'b0;
        end
        else if (MEM_WAIT) begin
            // do nothing
        end
        else begin
            trap_vec_mode <= TRAP_VEC_MODE;
            trap_vec_base <= TRAP_VEC_BASE;
            exec_reg_w_en <= EXEC_REG_W_EN;
            exec_reg_w_rd <= EXEC_REG_W_RD;
            exec_reg_w_data <= EXEC_REG_W_DATA;
            exec_csr_w_en <= EXEC_CSR_W_EN;
            exec_csr_w_addr <= EXEC_CSR_W_ADDR;
            exec_csr_w_data <= EXEC_CSR_W_DATA;
            exec_mem_r_en <= EXEC_MEM_R_EN;
            exec_mem_r_rd <= EXEC_MEM_R_RD;
            exec_mem_r_addr <= EXEC_MEM_R_ADDR;
            exec_mem_r_strb <= EXEC_MEM_R_STRB;
            exec_mem_r_signed <= EXEC_MEM_R_SIGNED;
            exec_mem_w_en <= EXEC_MEM_W_EN;
            exec_mem_w_addr <= EXEC_MEM_W_ADDR;
            exec_mem_w_strb <= EXEC_MEM_W_STRB;
            exec_mem_w_data <= EXEC_MEM_W_DATA;
            exec_jmp_do <= EXEC_JMP_DO;
            exec_jmp_pc <= EXEC_JMP_PC;
            exec_exc_en <= EXEC_EXC_EN;
            exec_exc_code <= EXEC_EXC_CODE;
            exec_exc_pc <= EXEC_EXC_PC;
        end
    end

    /* ----- 出力 ----- */
    assign CUSHION_REG_W_EN     = exec_exc_en ? 1'b0 : exec_reg_w_en;
    assign CUSHION_REG_W_RD     = exec_exc_en ? 5'b0 : exec_reg_w_rd;
    assign CUSHION_REG_W_DATA   = exec_exc_en ? 32'b0 : exec_reg_w_data;
    assign CUSHION_CSR_W_EN     = exec_exc_en ? 1'b0 : exec_csr_w_en;
    assign CUSHION_CSR_W_ADDR   = exec_exc_en ? 12'b0 : exec_csr_w_addr;
    assign CUSHION_CSR_W_DATA   = exec_exc_en ? 32'b0 : exec_csr_w_data;
    assign CUSHION_MEM_R_EN     = exec_exc_en ? 1'b0 : exec_mem_r_en;
    assign CUSHION_MEM_R_RD     = exec_exc_en ? 5'b0 : exec_mem_r_rd;
    assign CUSHION_MEM_R_ADDR   = exec_exc_en ? 32'b0 : exec_mem_r_addr;
    assign CUSHION_MEM_R_STRB   = exec_exc_en ? 4'b0 : exec_mem_r_strb;
    assign CUSHION_MEM_R_SIGNED = exec_exc_en ? 1'b0 : exec_mem_r_signed;
    assign CUSHION_MEM_W_EN     = exec_exc_en ? 1'b0 : exec_mem_w_en;
    assign CUSHION_MEM_W_ADDR   = exec_exc_en ? 32'b0 : exec_mem_w_addr;
    assign CUSHION_MEM_W_STRB   = exec_exc_en ? 4'b0 : exec_mem_w_strb;
    assign CUSHION_MEM_W_DATA   = exec_exc_en ? 32'b0 : exec_mem_w_data;
    assign CUSHION_JMP_DO       = exec_jmp_do || exec_exc_en;
    assign CUSHION_JMP_PC       = exec_jmp_do ? exec_jmp_pc : (trap_vec_mode == 2'b0 ? trap_vec_base : trap_vec_base + { 26'b0, exec_exc_code, 2'b0 });
    assign CUSHION_EXC_EN       = exec_exc_en;
    assign CUSHION_EXC_CODE     = exec_exc_code;
    assign CUSHION_EXC_PC       = exec_exc_pc;

endmodule

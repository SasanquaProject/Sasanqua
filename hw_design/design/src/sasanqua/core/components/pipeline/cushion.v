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
        // PC
        input wire  [31:0]  PC,

        // レジスタ(rv32i:W)
        input wire          REG_W_EN,
        input wire  [4:0]   REG_W_RD,
        input wire  [31:0]  REG_W_DATA,

        // レジスタ(csrs:W)
        input wire          CSR_W_EN,
        input wire  [11:0]  CSR_W_ADDR,
        input wire  [31:0]  CSR_W_DATA,

        // メモリ(R)
        input wire          MEM_R_EN,
        input wire  [4:0]   MEM_R_RD,
        input wire  [31:0]  MEM_R_ADDR,
        input wire  [3:0]   MEM_R_STRB,
        input wire          MEM_R_SIGNED,

        // メモリ(W)
        input wire          MEM_W_EN,
        input wire  [31:0]  MEM_W_ADDR,
        input wire  [3:0]   MEM_W_STRB,
        input wire  [31:0]  MEM_W_DATA,

        // PC更新
        input wire          JMP_DO,
        input wire  [31:0]  JMP_PC,

        // 例外
        input wire          EXC_EN,
        input wire  [3:0]   EXC_CODE,

        /* ----- 後段との接続 ----- */
        // PC
        output wire [31:0]  CUSHION_PC,

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
    reg         reg_w_en, csr_w_en, mem_r_en, mem_r_signed, mem_w_en, jmp_do, exc_en;
    reg [31:0]  pc, reg_w_data, csr_w_data, mem_r_addr, mem_w_addr, mem_w_data, jmp_pc;
    reg [11:0]  csr_w_addr;
    reg [4:0]   reg_w_rd, mem_r_rd;
    reg [3:0]   mem_r_strb, mem_w_strb, exc_code;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            pc <= 32'b0;
            reg_w_en <= 1'b0;
            reg_w_rd <= 5'b0;
            reg_w_data <= 32'b0;
            csr_w_en <= 1'b0;
            csr_w_addr <= 12'b0;
            csr_w_data <= 32'b0;
            mem_r_en <= 1'b0;
            mem_r_rd <= 5'b0;
            mem_r_addr <= 32'b0;
            mem_r_strb <= 4'b0;
            mem_r_signed <= 1'b0;
            mem_w_en <= 1'b0;
            mem_w_addr <= 32'b0;
            mem_w_strb <= 4'b0;
            mem_w_data <= 32'b0;
            jmp_do <= 1'b0;
            jmp_pc <= 32'b0;
            exc_en <= 1'b0;
            exc_code <= 4'b0;
        end
        else if (MEM_WAIT) begin
            // do nothing
        end
        else begin
            pc <= PC;
            reg_w_en <= REG_W_EN;
            reg_w_rd <= REG_W_RD;
            reg_w_data <= REG_W_DATA;
            csr_w_en <= CSR_W_EN;
            csr_w_addr <= CSR_W_ADDR;
            csr_w_data <= CSR_W_DATA;
            mem_r_en <= MEM_R_EN;
            mem_r_rd <= MEM_R_RD;
            mem_r_addr <= MEM_R_ADDR;
            mem_r_strb <= MEM_R_STRB;
            mem_r_signed <= MEM_R_SIGNED;
            mem_w_en <= MEM_W_EN;
            mem_w_addr <= MEM_W_ADDR;
            mem_w_strb <= MEM_W_STRB;
            mem_w_data <= MEM_W_DATA;
            jmp_do <= JMP_DO;
            jmp_pc <= JMP_PC;
            exc_en <= EXC_EN;
            exc_code <= EXC_CODE;
        end
    end

    /* ----- 出力 ----- */
    assign CUSHION_PC           = pc;
    assign CUSHION_REG_W_EN     = reg_w_en;
    assign CUSHION_REG_W_RD     = reg_w_rd;
    assign CUSHION_REG_W_DATA   = reg_w_data;
    assign CUSHION_CSR_W_EN     = csr_w_en;
    assign CUSHION_CSR_W_ADDR   = csr_w_addr;
    assign CUSHION_CSR_W_DATA   = csr_w_data;
    assign CUSHION_MEM_R_EN     = mem_r_en;
    assign CUSHION_MEM_R_RD     = mem_r_rd;
    assign CUSHION_MEM_R_ADDR   = mem_r_addr;
    assign CUSHION_MEM_R_STRB   = mem_r_strb;
    assign CUSHION_MEM_R_SIGNED = mem_r_signed;
    assign CUSHION_MEM_W_EN     = mem_w_en;
    assign CUSHION_MEM_W_ADDR   = mem_w_addr;
    assign CUSHION_MEM_W_STRB   = mem_w_strb;
    assign CUSHION_MEM_W_DATA   = mem_w_data;
    assign CUSHION_JMP_DO       = jmp_do;
    assign CUSHION_JMP_PC       = jmp_pc;
    assign CUSHION_EXC_EN       = exc_en;
    assign CUSHION_EXC_CODE     = exc_code;

endmodule

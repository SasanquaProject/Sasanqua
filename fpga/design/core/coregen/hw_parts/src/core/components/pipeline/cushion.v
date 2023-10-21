module cushion #
    (
        parameter COP_NUMS = 32'd1
    )
    (
        /* ----- 制御 ----- */
        // クロック・リセット
        input wire                      CLK,
        input wire                      RST,

        // パイプライン
        input wire                      FLUSH,
        input wire                      MEM_WAIT,

        /* ----- 前段との接続 ----- */
        // Main
        input wire                      MAIN_ALLOW,
        input wire                      MAIN_VALID,
        input wire  [31:0]              MAIN_PC,
        input wire                      MAIN_REG_W_EN,
        input wire  [4:0]               MAIN_REG_W_RD,
        input wire  [31:0]              MAIN_REG_W_DATA,
        input wire                      MAIN_CSR_W_EN,
        input wire  [11:0]              MAIN_CSR_W_ADDR,
        input wire  [31:0]              MAIN_CSR_W_DATA,
        input wire                      MAIN_MEM_R_EN,
        input wire  [4:0]               MAIN_MEM_R_RD,
        input wire  [31:0]              MAIN_MEM_R_ADDR,
        input wire  [3:0]               MAIN_MEM_R_STRB,
        input wire                      MAIN_MEM_R_SIGNED,
        input wire                      MAIN_MEM_W_EN,
        input wire  [31:0]              MAIN_MEM_W_ADDR,
        input wire  [3:0]               MAIN_MEM_W_STRB,
        input wire  [31:0]              MAIN_MEM_W_DATA,
        input wire                      MAIN_JMP_DO,
        input wire  [31:0]              MAIN_JMP_PC,
        input wire                      MAIN_EXC_EN,
        input wire  [3:0]               MAIN_EXC_CODE,

        // B (cop)
        input wire  [( 1*COP_NUMS-1):0] COP_ALLOW,
        input wire  [( 1*COP_NUMS-1):0] COP_VALID,
        input wire  [(32*COP_NUMS-1):0] COP_PC,
        input wire  [( 1*COP_NUMS-1):0] COP_REG_W_EN,
        input wire  [( 5*COP_NUMS-1):0] COP_REG_W_RD,
        input wire  [(32*COP_NUMS-1):0] COP_REG_W_DATA,
        input wire  [( 1*COP_NUMS-1):0] COP_EXC_EN,
        input wire  [( 4*COP_NUMS-1):0] COP_EXC_CODE,

        /* ----- 後段との接続 ----- */
        output wire                     CUSHION_VALID,
        output wire [31:0]              CUSHION_PC,
        output wire                     CUSHION_REG_W_EN,
        output wire [4:0]               CUSHION_REG_W_RD,
        output wire [31:0]              CUSHION_REG_W_DATA,
        output wire                     CUSHION_CSR_W_EN,
        output wire [11:0]              CUSHION_CSR_W_ADDR,
        output wire [31:0]              CUSHION_CSR_W_DATA,
        output wire                     CUSHION_MEM_R_EN,
        output wire [4:0]               CUSHION_MEM_R_RD,
        output wire [31:0]              CUSHION_MEM_R_ADDR,
        output wire [3:0]               CUSHION_MEM_R_STRB,
        output wire                     CUSHION_MEM_R_SIGNED,
        output wire                     CUSHION_MEM_W_EN,
        output wire [31:0]              CUSHION_MEM_W_ADDR,
        output wire [3:0]               CUSHION_MEM_W_STRB,
        output wire [31:0]              CUSHION_MEM_W_DATA,
        output wire                     CUSHION_JMP_DO,
        output wire [31:0]              CUSHION_JMP_PC,
        output wire                     CUSHION_EXC_EN,
        output wire [3:0]               CUSHION_EXC_CODE,
        output wire [31:0]              CUSHION_EXC_PC
    );

    /* ----- 入力取り込み ----- */
    // A (main stream)
    reg                     main_allow, main_valid;
    reg                     main_reg_w_en, main_csr_w_en, main_mem_r_en, main_mem_r_signed, main_mem_w_en;
    reg                     main_jmp_do, main_exc_en;
    reg [31:0]              main_pc, main_reg_w_data, main_csr_w_data, main_mem_r_addr, main_mem_w_addr, main_mem_w_data, main_jmp_pc;
    reg [11:0]              main_csr_w_addr;
    reg [4:0]               main_reg_w_rd, main_mem_r_rd;
    reg [3:0]               main_mem_r_strb, main_mem_w_strb, main_exc_code;

    // B (cop)
    reg [( 1*COP_NUMS-1):0] cop_allow, cop_valid, cop_reg_w_en, cop_exc_en;
    reg [(32*COP_NUMS-1):0] cop_pc, cop_reg_w_data;
    reg [( 5*COP_NUMS-1):0] cop_reg_w_rd;
    reg [( 4*COP_NUMS-1):0] cop_exc_code;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            main_allow <= 1'b0;
            main_valid <= 1'b0;
            main_pc <= 32'b0;
            main_reg_w_en <= 1'b0;
            main_reg_w_rd <= 5'b0;
            main_reg_w_data <= 32'b0;
            main_csr_w_en <= 1'b0;
            main_csr_w_addr <= 12'b0;
            main_csr_w_data <= 32'b0;
            main_mem_r_en <= 1'b0;
            main_mem_r_rd <= 5'b0;
            main_mem_r_addr <= 32'b0;
            main_mem_r_strb <= 4'b0;
            main_mem_r_signed <= 1'b0;
            main_mem_w_en <= 1'b0;
            main_mem_w_addr <= 32'b0;
            main_mem_w_strb <= 4'b0;
            main_mem_w_data <= 32'b0;
            main_jmp_do <= 1'b0;
            main_jmp_pc <= 32'b0;
            main_exc_en <= 1'b0;
            main_exc_code <= 4'b0;
            cop_allow <= 'b0;
            cop_valid <= 'b0;
            cop_pc <= 'b0;
            cop_reg_w_en <= 'b0;
            cop_reg_w_rd <= 'b0;
            cop_reg_w_data <= 'b0;
            cop_exc_en <= 'b0;
            cop_exc_code <= 'b0;
        end
        else if (MEM_WAIT) begin
            // do nothing
        end
        else begin
            main_allow <= MAIN_ALLOW;
            main_valid <= MAIN_VALID;
            main_pc <= MAIN_PC;
            main_reg_w_en <= MAIN_REG_W_EN;
            main_reg_w_rd <= MAIN_REG_W_RD;
            main_reg_w_data <= MAIN_REG_W_DATA;
            main_csr_w_en <= MAIN_CSR_W_EN;
            main_csr_w_addr <= MAIN_CSR_W_ADDR;
            main_csr_w_data <= MAIN_CSR_W_DATA;
            main_mem_r_en <= MAIN_MEM_R_EN;
            main_mem_r_rd <= MAIN_MEM_R_RD;
            main_mem_r_addr <= MAIN_MEM_R_ADDR;
            main_mem_r_strb <= MAIN_MEM_R_STRB;
            main_mem_r_signed <= MAIN_MEM_R_SIGNED;
            main_mem_w_en <= MAIN_MEM_W_EN;
            main_mem_w_addr <= MAIN_MEM_W_ADDR;
            main_mem_w_strb <= MAIN_MEM_W_STRB;
            main_mem_w_data <= MAIN_MEM_W_DATA;
            main_jmp_do <= MAIN_JMP_DO;
            main_jmp_pc <= MAIN_JMP_PC;
            main_exc_en <= MAIN_EXC_EN;
            main_exc_code <= MAIN_EXC_CODE;
            cop_allow <= COP_ALLOW;
            cop_valid <= COP_VALID;
            cop_pc <= COP_PC;
            cop_reg_w_en <= COP_REG_W_EN;
            cop_reg_w_rd <= COP_REG_W_RD;
            cop_reg_w_data <= COP_REG_W_DATA;
            cop_exc_en <= COP_EXC_EN;
            cop_exc_code <= COP_EXC_CODE;
        end
    end

    /* ----- 出力 ----- */
    wire main_ok = !main_allow || main_valid;
    wire cop_ok = !cop_allow || cop_valid;
    wire ok   = main_ok && cop_ok;

    wire [31:0] merge_pc         = main_ok ? main_pc :
                                  (cop_ok ? cop_pc : 32'b0);
    wire        merge_reg_w_en   = main_ok ? main_reg_w_en :
                                  (cop_ok ? cop_reg_w_en : 1'b0);
    wire [4:0]  merge_reg_w_rd   = main_ok ? main_reg_w_rd :
                                  (cop_ok ? cop_reg_w_rd : 5'b0);
    wire [31:0] merge_reg_w_data = main_ok ? main_reg_w_data :
                                  (cop_ok ? cop_reg_w_data : 32'b0);
    wire        merge_exc_en     = main_ok ? main_exc_en :
                                  (cop_ok ? cop_exc_en : 1'b0);
    wire [4:0]  merge_exc_code   = main_ok ? main_exc_code :
                                  (cop_ok ? cop_exc_code : 5'b0);

    assign CUSHION_VALID         = ok;
    assign CUSHION_PC            = ok ? merge_pc : 32'b0;
    assign CUSHION_REG_W_EN      = ok ? merge_reg_w_en : 1'b0;
    assign CUSHION_REG_W_RD      = ok ? merge_reg_w_rd : 5'b0;
    assign CUSHION_REG_W_DATA    = ok ? merge_reg_w_data : 32'b0;
    assign CUSHION_CSR_W_EN      = ok ? main_csr_w_en : 1'b0;
    assign CUSHION_CSR_W_ADDR    = ok ? main_csr_w_addr : 12'b0;
    assign CUSHION_CSR_W_DATA    = ok ? main_csr_w_data : 32'b0;
    assign CUSHION_MEM_R_EN      = ok ? main_mem_r_en : 1'b0;
    assign CUSHION_MEM_R_RD      = ok ? main_mem_r_rd : 5'b0;
    assign CUSHION_MEM_R_ADDR    = ok ? main_mem_r_addr : 32'b0;
    assign CUSHION_MEM_R_STRB    = ok ? main_mem_r_strb : 4'b0;
    assign CUSHION_MEM_R_SIGNED  = ok ? main_mem_r_signed : 1'b0;
    assign CUSHION_MEM_W_EN      = ok ? main_mem_w_en : 1'b0;
    assign CUSHION_MEM_W_ADDR    = ok ? main_mem_w_addr : 32'b0;
    assign CUSHION_MEM_W_STRB    = ok ? main_mem_w_strb : 4'b0;
    assign CUSHION_MEM_W_DATA    = ok ? main_mem_w_data : 32'b0;
    assign CUSHION_JMP_DO        = ok ? main_jmp_do : 1'b0;
    assign CUSHION_JMP_PC        = ok ? main_jmp_pc : 32'b0;
    assign CUSHION_EXC_EN        = ok ? merge_exc_en : 1'b0;
    assign CUSHION_EXC_CODE      = ok ? merge_exc_code : 4'b0;

endmodule

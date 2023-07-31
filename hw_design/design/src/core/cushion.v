module cushion
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          FLUSH,
        input wire          STALL,

        /* ----- 実行部との接続 ----- */
        // レジスタ(W)
        input wire  [4:0]   EXEC_REG_W_RD,
        input wire  [31:0]  EXEC_REG_W_DATA,

        // メモリ(R)
        input wire          EXEC_MEM_R_VALID,
        input wire  [4:0]   EXEC_MEM_R_RD,
        input wire  [31:0]  EXEC_MEM_R_ADDR,
        input wire  [3:0]   EXEC_MEM_R_STRB,
        input wire          EXEC_MEM_R_SIGNED,

        // メモリ(W)
        input wire          EXEC_MEM_W_VALID,
        input wire  [31:0]  EXEC_MEM_W_ADDR,
        input wire  [3:0]   EXEC_MEM_W_STRB,
        input wire  [31:0]  EXEC_MEM_W_DATA,

        // PC更新
        input wire          EXEC_JMP_DO,
        input wire  [31:0]  EXEC_JMP_PC,

        /* ----- メモリアクセス(r)部との接続 ----- */
        // レジスタ(W)
        output wire [4:0]   CUSHION_REG_W_RD,
        output wire [31:0]  CUSHION_REG_W_DATA,

        // メモリ(R)
        output wire         CUSHION_MEM_R_VALID,
        output wire [4:0]   CUSHION_MEM_R_RD,
        output wire [31:0]  CUSHION_MEM_R_ADDR,
        output wire [3:0]   CUSHION_MEM_R_STRB,
        output wire         CUSHION_MEM_R_SIGNED,

        // メモリ(W)
        output wire         CUSHION_MEM_W_VALID,
        output wire [31:0]  CUSHION_MEM_W_ADDR,
        output wire [3:0]   CUSHION_MEM_W_STRB,
        output wire [31:0]  CUSHION_MEM_W_DATA,

        // PC更新
        output wire         CUSHION_JMP_DO,
        output wire [31:0]  CUSHION_JMP_PC
    );

    /* ----- 入力取り込み ----- */
    reg         exec_mem_r_valid, exec_mem_r_signed, exec_mem_w_valid, exec_jmp_do;
    reg [31:0]  exec_reg_w_data, exec_mem_r_addr, exec_mem_w_addr, exec_mem_w_data, exec_jmp_pc;
    reg [4:0]   exec_reg_w_rd, exec_mem_r_rd;
    reg [3:0]   exec_mem_r_strb, exec_mem_w_strb;

    always @ (posedge CLK) begin
        if (RST || FLUSH) begin
            exec_reg_w_rd <= 5'b0;
            exec_reg_w_data <= 32'b0;
            exec_mem_r_valid <= 1'b0;
            exec_mem_r_rd <= 5'b0;
            exec_mem_r_addr <= 32'b0;
            exec_mem_r_strb <= 4'b0;
            exec_mem_r_signed <= 1'b0;
            exec_mem_w_valid <= 1'b0;
            exec_mem_w_addr <= 32'b0;
            exec_mem_w_strb <= 4'b0;
            exec_mem_w_data <= 32'b0;
            exec_jmp_do <= 1'b0;
            exec_jmp_pc <= 32'b0;
        end
        else if (STALL) begin
            // do nothing
        end
        else begin
            exec_reg_w_rd <= EXEC_REG_W_RD;
            exec_reg_w_data <= EXEC_REG_W_DATA;
            exec_mem_r_valid <= EXEC_MEM_R_VALID;
            exec_mem_r_rd <= EXEC_MEM_R_RD;
            exec_mem_r_addr <= EXEC_MEM_R_ADDR;
            exec_mem_r_strb <= EXEC_MEM_R_STRB;
            exec_mem_r_signed <= EXEC_MEM_R_SIGNED;
            exec_mem_w_valid <= EXEC_MEM_W_VALID;
            exec_mem_w_addr <= EXEC_MEM_W_ADDR;
            exec_mem_w_strb <= EXEC_MEM_W_STRB;
            exec_mem_w_data <= EXEC_MEM_W_DATA;
            exec_jmp_do <= EXEC_JMP_DO;
            exec_jmp_pc <= EXEC_JMP_PC;
        end
    end

    /* ----- 出力 ----- */
    assign CUSHION_REG_W_RD     = exec_reg_w_rd;
    assign CUSHION_REG_W_DATA   = exec_reg_w_data;
    assign CUSHION_MEM_R_VALID  = exec_mem_r_valid;
    assign CUSHION_MEM_R_RD     = exec_mem_r_rd;
    assign CUSHION_MEM_R_ADDR   = exec_mem_r_addr;
    assign CUSHION_MEM_R_STRB   = exec_mem_r_strb;
    assign CUSHION_MEM_R_SIGNED = exec_mem_r_signed;
    assign CUSHION_MEM_W_VALID  = exec_mem_w_valid;
    assign CUSHION_MEM_W_ADDR   = exec_mem_w_addr;
    assign CUSHION_MEM_W_STRB   = exec_mem_w_strb;
    assign CUSHION_MEM_W_DATA   = exec_mem_w_data;
    assign CUSHION_JMP_DO       = exec_jmp_do;
    assign CUSHION_JMP_PC       = exec_jmp_pc;

endmodule

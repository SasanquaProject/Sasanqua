module mread
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          STALL,

        /* ----- 待機部との接続 ----- */
        // レジスタ(W)
        input wire  [4:0]   CUSHION_REG_W_RD,
        input wire  [31:0]  CUSHION_REG_W_DATA,

        // メモリ(R)
        input wire          CUSHION_MEM_R_VALID,
        input wire  [4:0]   CUSHION_MEM_R_RD,
        input wire  [31:0]  CUSHION_MEM_R_ADDR,
        input wire  [3:0]   CUSHION_MEM_R_STRB,
        input wire          CUSHION_MEM_R_SIGNED,

        // メモリ(W)
        input wire          CUSHION_MEM_W_VALID,
        input wire  [31:0]  CUSHION_MEM_W_ADDR,
        input wire  [3:0]   CUSHION_MEM_W_STRB,
        input wire  [31:0]  CUSHION_MEM_W_DATA,

        /* ----- メモリアクセス(w)部との接続 ----- */
        // レジスタ(W)
        output wire [4:0]   MEMR_REG_W_RD,
        output wire [31:0]  MEMR_REG_W_DATA,

        // メモリ(W)
        output wire         MEMR_MEM_W_VALID,
        output wire [31:0]  MEMR_MEM_W_ADDR,
        output wire [3:0]   MEMR_MEM_W_STRB,
        output wire [31:0]  MEMR_MEM_W_DATA
    );

    /* ----- 入力取り込み ----- */
    reg         cushion_mem_r_valid, cushion_mem_r_signed, cushion_mem_w_valid;
    reg [31:0]  cushion_reg_w_data, cushion_mem_r_addr, cushion_mem_w_addr, cushion_mem_w_data;
    reg [4:0]   cushion_reg_w_rd, cushion_mem_r_rd;
    reg [3:0]   cushion_mem_r_strb, cushion_mem_w_strb;

    always @ (posedge CLK) begin
        if (RST) begin
            cushion_reg_w_rd <= 5'b0;
            cushion_reg_w_data <= 32'b0;
            cushion_mem_r_valid <= 1'b0;
            cushion_mem_r_rd <= 5'b0;
            cushion_mem_r_addr <= 32'b0;
            cushion_mem_r_strb <= 4'b0;
            cushion_mem_r_signed <= 1'b0;
            cushion_mem_w_valid <= 1'b0;
            cushion_mem_w_addr <= 32'b0;
            cushion_mem_w_strb <= 4'b0;
            cushion_mem_w_data <= 32'b0;
        end
        else if (STALL) begin
            // do nothing
        end
        else begin
            cushion_reg_w_rd <= CUSHION_REG_W_RD;
            cushion_reg_w_data <= CUSHION_REG_W_DATA;
            cushion_mem_r_valid <= CUSHION_MEM_R_VALID;
            cushion_mem_r_rd <= CUSHION_MEM_R_RD;
            cushion_mem_r_addr <= CUSHION_MEM_R_ADDR;
            cushion_mem_r_strb <= CUSHION_MEM_R_STRB;
            cushion_mem_r_signed <= CUSHION_MEM_R_SIGNED;
            cushion_mem_w_valid <= CUSHION_MEM_W_VALID;
            cushion_mem_w_addr <= CUSHION_MEM_W_ADDR;
            cushion_mem_w_strb <= CUSHION_MEM_W_STRB;
            cushion_mem_w_data <= CUSHION_MEM_W_DATA;
        end
    end

    /* ----- 出力 ----- */
    assign MEMR_REG_W_RD     = cushion_reg_w_rd;
    assign MEMR_REG_W_DATA   = cushion_reg_w_data;
    assign MEMR_MEM_W_VALID  = cushion_mem_w_valid;
    assign MEMR_MEM_W_ADDR   = cushion_mem_w_addr;
    assign MEMR_MEM_W_STRB   = cushion_mem_w_strb;
    assign MEMR_MEM_W_DATA   = cushion_mem_w_data;

endmodule

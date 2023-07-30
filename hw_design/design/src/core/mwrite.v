module mwrite
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          STALL,

        /* ----- メモリアクセス(r)部との接続 ----- */
        input wire  [4:0]   MEMR_REG_W_RD,
        input wire  [31:0]  MEMR_REG_W_DATA,
        input wire          MEMR_MEM_W_VALID,
        input wire  [31:0]  MEMR_MEM_W_ADDR,
        input wire  [3:0]   MEMR_MEM_W_STRB,
        input wire  [31:0]  MEMR_MEM_W_DATA,

        /* ----- データフォワーディング用 ----- */
        output wire [4:0]   MEMW_REG_W_RD,
        output wire [31:0]  MEMW_REG_W_DATA
    );

    /* -----  入力取り込み ----- */
    reg         memr_mem_w_valid;
    reg  [31:0] memr_reg_w_data, memr_mem_w_addr, memr_mem_w_data;
    reg  [4:0]  memr_reg_w_rd;
    reg  [3:0]  memr_mem_w_strb;

    always @ (posedge CLK) begin
        if (RST) begin
            memr_reg_w_rd <= 5'b0;
            memr_reg_w_data <= 32'b0;
            memr_mem_w_valid <= 1'b0;
            memr_mem_w_addr <= 32'b0;
            memr_mem_w_strb <= 4'b0;
            memr_mem_w_data <= 32'b0;
        end
        else if (STALL) begin
            // do nothing
        end
        else begin
            memr_reg_w_rd <= MEMR_REG_W_RD;
            memr_reg_w_data <= MEMR_REG_W_DATA;
            memr_mem_w_valid <= MEMR_MEM_W_VALID;
            memr_mem_w_addr <= MEMR_MEM_W_ADDR;
            memr_mem_w_strb <= MEMR_MEM_W_STRB;
            memr_mem_w_data <= MEMR_MEM_W_DATA;
        end
    end

    /* ----- 出力 ----- */
    assign MEMW_REG_W_RD    = memr_reg_w_rd;
    assign MEMW_REG_W_DATA  = memr_reg_w_data;

endmodule

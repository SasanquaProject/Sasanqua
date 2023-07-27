module mwrite
    (
        /* ----- 制御 ----- */
        input               CLK,
        input               RST,

        /* ----- メモリアクセス(w)部との接続 ----- */
        output wire         MEMR_MEM_W_VALID,
        output wire [31:0]  MEMR_MEM_W_ADDR,
        output wire [3:0]   MEMR_MEM_W_STRB,
        output wire [31:0]  MEMR_MEM_W_DATA
    );

    /* -----  入力取り込み ----- */
    reg         memr_mem_w_valid;
    reg  [31:0] memr_mem_w_addr, memr_mem_w_data;
    reg  [3:0]  memr_mem_w_strb;

    always @ (posedge CLK) begin
        memr_mem_w_valid <= MEMR_MEM_W_VALID;
        memr_mem_w_addr <= MEMR_MEM_W_ADDR;
        memr_mem_w_strb <= MEMR_MEM_W_STRB;
        memr_mem_w_data <= MEMR_MEM_W_DATA;
    end

endmodule

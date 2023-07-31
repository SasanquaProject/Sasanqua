module mwrite
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          STALL,

        /* ----- MMUとの接続 ----- */
        output wire         DATA_WREN,
        output wire [31:0]  DATA_WADDR,
        output wire [3:0]   DATA_WSTRB,
        output wire [31:0]  DATA_WDATA,

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

    /* ----- MMUとの接続 ----- */
    assign DATA_WREN    = MEMR_MEM_W_VALID;
    assign DATA_WADDR   = MEMR_MEM_W_ADDR;
    assign DATA_WSTRB   = MEMR_MEM_W_STRB;
    assign DATA_WDATA   = MEMR_MEM_W_DATA;

    /* -----  入力取り込み ----- */
    reg  [31:0] memr_reg_w_data;
    reg  [4:0]  memr_reg_w_rd;

    always @ (posedge CLK) begin
        if (RST) begin
            memr_reg_w_rd <= 5'b0;
            memr_reg_w_data <= 32'b0;
        end
        else if (STALL) begin
            // do nothing
        end
        else begin
            memr_reg_w_rd <= MEMR_REG_W_RD;
            memr_reg_w_data <= MEMR_REG_W_DATA;
        end
    end

    /* ----- 出力 ----- */
    assign MEMW_REG_W_RD    = memr_reg_w_rd;
    assign MEMW_REG_W_DATA  = memr_reg_w_data;

endmodule

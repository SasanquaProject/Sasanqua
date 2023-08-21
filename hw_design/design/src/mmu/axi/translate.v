module translate_axi
    (
        /* ----- 制御 ----- */
        // クロック, リセット
        input wire          CLK,
        input wire          RST,
        input wire          STALL,
        output wire         LOADING,

        /* ----- メモリアクセス ----- */
        // 読み
        input wire          RDEN,
        input wire  [31:0]  RIADDR,
        output reg  [31:0]  ROADDR,
        output reg          RVALID,
        output reg  [31:0]  RDATA,

        // 書き
        input wire          WREN,
        input wire  [31:0]  WADDR,
        input wire  [31:0]  WDATA,

        /* ----- AXIバス ----- */
        // AWチャネル
        output reg  [31:0]  M_AXI_AWADDR,
        output reg  [7:0]   M_AXI_AWLEN,
        output wire [2:0]   M_AXI_AWSIZE,
        output wire [1:0]   M_AXI_AWBURST,
        output reg          M_AXI_AWVALID,
        input  wire         M_AXI_AWREADY,

        // Wチャネル
        output reg  [31:0]  M_AXI_WDATA,
        output reg  [3:0]   M_AXI_WSTRB,
        output reg          M_AXI_WLAST,
        output reg          M_AXI_WVALID,
        input  wire         M_AXI_WREADY,

        // Bチャネル
        input  wire         M_AXI_BID,
        input  wire [1:0]   M_AXI_BRESP,
        input  wire         M_AXI_BVALID,

        // ARチャネル
        output reg  [31:0]  M_AXI_ARADDR,
        output reg  [7:0]   M_AXI_ARLEN,
        output wire [2:0]   M_AXI_ARSIZE,
        output wire [1:0]   M_AXI_ARBURST,
        output reg          M_AXI_ARVALID,
        input  wire         M_AXI_ARREADY,

        // Rチャネル
        input  wire         M_AXI_RID,
        input  wire [31:0]  M_AXI_RDATA,
        input  wire [1:0]   M_AXI_RRESP,
        input  wire         M_AXI_RLAST,
        input  wire         M_AXI_RVALID
    );

    assign LOADING = (RDEN && sr_next_state != S_SR_IDLE) || (WREN && sw_next_state != S_SW_IDLE);

    /* ----- AXIバス設定 ----- */
    assign M_AXI_AWSIZE    = 3'b010;
    assign M_AXI_AWBURST   = 2'b01;
    assign M_AXI_ARSIZE    = 3'b010;
    assign M_AXI_ARBURST   = 2'b01;

    /* ----- メモリアクセス(R) ----- */
    always @ (posedge CLK) begin
        if (RST) begin
            ROADDR <= 32'b0;
            RVALID <= 1'b0;
            RDATA <= 32'b0;
        end
        else if (RDEN && M_AXI_RVALID) begin
            ROADDR <= RIADDR;
            RVALID <= 1'b1;
            RDATA <= M_AXI_RDATA;
        end
        else if (STALL) begin
            // do nothing
        end
        else begin
            RVALID <= 1'b0;
            RDATA <= 32'b0;
        end
    end

    /* ----- AR, Rチャネル用ステートマシン ----- */
    parameter S_SR_IDLE   = 2'b00;
    parameter S_SR_ADDR   = 2'b01;
    parameter S_SR_WAIT   = 2'b11;
    parameter S_SR_FINISH = 2'b10;

    reg [1:0]  sr_state, sr_next_state;

    always @ (posedge CLK) begin
        if (RST)
            sr_state <= S_SR_IDLE;
        else
            sr_state <= sr_next_state;
    end

    always @* begin
        case (sr_state)
            S_SR_IDLE:
                if (RDEN)
                    sr_next_state <= S_SR_ADDR;
                else
                    sr_next_state <= S_SR_IDLE;

            S_SR_ADDR:
                if (M_AXI_ARREADY)
                    sr_next_state <= S_SR_WAIT;
                else
                    sr_next_state <= S_SR_ADDR;

            S_SR_WAIT:
                if (M_AXI_RVALID)
                    sr_next_state <= S_SR_FINISH;
                else
                    sr_next_state <= S_SR_WAIT;

            S_SR_FINISH:
                if (!WREN || sw_state == S_SW_FINISH)
                    sr_next_state <= S_SR_IDLE;
                else
                    sr_next_state <= S_SR_FINISH;

            default:
                sr_next_state <= S_SR_IDLE;
        endcase
    end

    always @ (posedge CLK) begin
        if (RST) begin
            M_AXI_ARADDR <= 32'b0;
            M_AXI_ARLEN <= 8'b0;
            M_AXI_ARVALID <= 1'b0;
        end
        else if (sr_next_state == S_SR_ADDR) begin
            M_AXI_ARADDR <= RIADDR;
            M_AXI_ARLEN <= 8'b0;
            M_AXI_ARVALID <= 1'b1;
        end
        else if (sr_state == S_SR_ADDR && M_AXI_ARREADY) begin
            M_AXI_ARADDR <= 32'b0;
            M_AXI_ARLEN <= 8'b0;
            M_AXI_ARVALID <= 1'b0;
        end
    end

    /* ----- AW, Wチャネル用ステートマシン ----- */
    parameter S_SW_IDLE   = 2'b00;
    parameter S_SW_ADDR   = 2'b01;
    parameter S_SW_WRITE  = 2'b11;
    parameter S_SW_FINISH = 2'b10;

    reg [1:0] sw_state, sw_next_state;

    always @ (posedge CLK) begin
        if (RST)
            sw_state <= S_SW_IDLE;
        else
            sw_state <= sw_next_state;
    end

    always @* begin
        case (sw_state)
            S_SW_IDLE:
                if (WREN)
                    sw_next_state <= S_SW_ADDR;
                else
                    sw_next_state <= S_SW_IDLE;

            S_SW_ADDR:
                if (M_AXI_AWREADY)
                    sw_next_state <= S_SW_WRITE;
                else
                    sw_next_state <= S_SW_ADDR;

            S_SW_WRITE:
                if (M_AXI_WREADY)
                    sw_next_state <= S_SW_FINISH;
                else
                    sw_next_state <= S_SW_WRITE;

            S_SW_FINISH:
                if (!RDEN || sr_state == S_SR_FINISH)
                    sw_next_state <= S_SW_IDLE;
                else
                    sw_next_state <= S_SW_FINISH;

            default:
                sw_next_state <= S_SW_IDLE;
        endcase
    end

    always @ (posedge CLK) begin
        if (RST) begin
            M_AXI_AWADDR <= 32'b0;
            M_AXI_AWLEN <= 8'b0;
            M_AXI_AWVALID <= 1'b0;
        end
        else if (sw_next_state == S_SW_ADDR) begin
            M_AXI_AWADDR <= WADDR;
            M_AXI_AWLEN <= 8'b0;
            M_AXI_AWVALID <= 1'b1;
        end
        else if (sw_state == S_SW_ADDR && sw_next_state == S_SW_WRITE) begin
            M_AXI_AWADDR <= 32'b0;
            M_AXI_AWLEN <= 8'b0;
            M_AXI_AWVALID <= 1'b0;
        end
    end

    always @ (posedge CLK) begin
        if (RST || sw_next_state == S_SW_IDLE) begin
            M_AXI_WDATA <= 32'b0;
            M_AXI_WSTRB <= 4'b1111;
            M_AXI_WLAST <= 1'b0;
            M_AXI_WVALID <= 1'b0;
        end
        else if (sw_next_state == S_SW_ADDR) begin
            M_AXI_WDATA <= WDATA;
            M_AXI_WLAST <= 1'b1;
            M_AXI_WVALID <= 1'b1;
        end
    end

endmodule

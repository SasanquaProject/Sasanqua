module cache_axi
    (
        /* ----- 制御 ----- */
        // クロック, リセット
        input wire          CLK,
        input wire          RST,
        input wire          STALL,

        /* ----- メモリアクセス ----- */
        // ヒットチェック
        input wire  [31:0]  HIT_CHECK,
        output wire         HIT_CHECK_RESULT,

        // 読み
        input wire          RDEN,
        input wire  [31:0]  RIADDR,
        output reg  [31:0]  ROADDR,
        output reg          RVALID,
        output reg  [31:0]  RDATA,

        // 書き
        input wire          WREN,
        input wire  [31:0]  WADDR,
        input wire  [3:0]   WSTRB,
        input wire  [31:0]  WDATA,

        /* ----- AXIバス ----- */
        // クロック・リセット
        input wire          M_AXI_CLK,
        input wire          M_AXI_RSTN,

        // AWチャネル
        output wire [31:0]  M_AXI_AWADDR,
        output wire [7:0]   M_AXI_AWLEN,
        output wire [2:0]   M_AXI_AWSIZE,
        output wire [1:0]   M_AXI_AWBURST,
        output wire         M_AXI_AWVALID,
        input  wire         M_AXI_AWREADY,

        // Wチャネル
        output wire [31:0]  M_AXI_WDATA,
        output wire [3:0]   M_AXI_WSTRB,
        output wire         M_AXI_WLAST,
        output wire         M_AXI_WVALID,
        input  wire         M_AXI_WREADY,

        // Bチャネル
        input  wire         M_AXI_BID,
        input  wire [1:0]   M_AXI_BRESP,
        input  wire         M_AXI_BVALID,

        // ARチャネル
        output reg  [31:0]  M_AXI_ARADDR,
        output wire [7:0]   M_AXI_ARLEN,
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

    /* ----- AXIバス設定 ----- */
    assign M_AXI_AWADDR     = 32'b0;
    assign M_AXI_AWLEN      = 8'b0;
    assign M_AXI_AWSIZE     = 3'b010;
    assign M_AXI_AWBURST    = 2'b01;
    assign M_AXI_AWVALID    = 1'b0;
    assign M_AXI_WDATA      = 32'b0;
    assign M_AXI_WSTRB      = 4'b1111;
    assign M_AXI_WLAST      = 1'b0;
    assign M_AXI_WVALID     = 1'b0;
    assign M_AXI_ARLEN      = 8'h1f;
    assign M_AXI_ARSIZE     = 3'b010;
    assign M_AXI_ARBURST    = 2'b01;

    /* ----- キャッシュ ----- */
    reg [19:0]  cached_addr;
    reg [31:0]  cache [0:1023];

    // アクセス(r)
    assign HIT_CHECK_RESULT = !RDEN || HIT_CHECK[31:12] == cached_addr;

    always @ (posedge CLK) begin
        if (RST) begin
            ROADDR <= 32'b0;
            RVALID <= 1'b0;
            RDATA <= 32'b0;
        end
        else if (STALL) begin
            // do nothing
        end
        else begin
            ROADDR <= RIADDR;
            RVALID <= RDEN && RIADDR[31:12] == cached_addr;
            RDATA <= RDEN && RIADDR[31:12] == cached_addr ? (
                        WREN && RIADDR[11:2] == WADDR[11:2] ?
                            gen_wrdata(WSTRB, cache[WADDR[11:2]], WDATA) :
                            cache[RIADDR[11:2]]
                    ) : 32'b0;
        end
    end

    // アクセス(w)
    reg  [9:0]  wrcnt;

    always @ (posedge CLK) begin
        if (RST)
            wrcnt <= 10'b0;
        else if (WREN)
            cache[WADDR[11:2]] <= gen_wrdata(WSTRB, cache[WADDR[11:2]], WDATA);
        else if (ar_state == S_AR_IDLE)
            wrcnt <= 10'b0;
        else if (r_state == S_R_READ && M_AXI_RVALID) begin
            wrcnt <= wrcnt + 10'b1;
            cache[wrcnt] <= M_AXI_RDATA;
        end
    end

    always @ (posedge CLK) begin
        if (RST)
            cached_addr <= 20'hf_ffff;
        else if (ar_state == S_AR_WAIT && ar_next_state == S_AR_IDLE) begin
            cached_addr <= RIADDR[31:12];
        end
    end

    function [31:0] gen_wrdata;
        input [3:0]     STRB;
        input [31:0]    A;
        input [31:0]    B;

        case (STRB)
            4'b0001: gen_wrdata = (A & 32'hffff_ff00) | (B & 32'h0000_00ff);
            4'b0010: gen_wrdata = (A & 32'hffff_00ff) | (B & 32'h0000_ff00);
            4'b0100: gen_wrdata = (A & 32'hff00_ffff) | (B & 32'h00ff_0000);
            4'b1000: gen_wrdata = (A & 32'h00ff_ffff) | (B & 32'hff00_0000);
            4'b0011: gen_wrdata = (A & 32'hffff_0000) | (B & 32'h0000_ffff);
            4'b0110: gen_wrdata = (A & 32'hff00_00ff) | (B & 32'h00ff_ff00);
            4'b1100: gen_wrdata = (A & 32'h0000_ffff) | (B & 32'hffff_0000);
            default: gen_wrdata = B;
        endcase
    endfunction

    /* ----- RAMアクセス ------ */
    // ARチャネル用ステートマシン
    parameter S_AR_IDLE = 2'b00;
    parameter S_AR_ADDR = 2'b01;
    parameter S_AR_WAIT = 2'b11;

    reg [1:0] ar_state, ar_next_state;

    always @ (posedge CLK) begin
        if (RST)
            ar_state <= S_AR_IDLE;
        else
            ar_state <= ar_next_state;
    end

    always @* begin
        case (ar_state)
            S_AR_IDLE:
                if (RDEN && RIADDR[31:12] != cached_addr)
                    ar_next_state <= S_AR_ADDR;
                else
                    ar_next_state <= S_AR_IDLE;

            S_AR_ADDR:
                if (M_AXI_ARREADY)
                    ar_next_state <= S_AR_WAIT;
                else
                    ar_next_state <= S_AR_ADDR;

            S_AR_WAIT:
                if (M_AXI_RVALID && M_AXI_RLAST) begin
                    if (M_AXI_ARADDR[11:0] == 12'b0)
                        ar_next_state <= S_AR_IDLE;
                    else
                        ar_next_state <= S_AR_ADDR;
                end
                else
                    ar_next_state <= S_AR_WAIT;

            default:
                ar_next_state <= S_AR_IDLE;
        endcase
    end

    always @ (posedge CLK) begin
        if (RST) begin
            M_AXI_ARADDR <= 32'h0;
            M_AXI_ARVALID <= 1'b0;
        end
        else if (ar_state == S_AR_IDLE && ar_next_state == S_AR_ADDR)
            M_AXI_ARADDR <= { RIADDR[31:12], 12'b0 };
        else if (ar_next_state == S_AR_ADDR)
            M_AXI_ARVALID <= 1'b1;
        else if (ar_state == S_AR_ADDR && M_AXI_ARREADY) begin
            M_AXI_ARADDR <= M_AXI_ARADDR + 32'd128;
            M_AXI_ARVALID <= 1'b0;
        end
        else if (ar_next_state == S_AR_IDLE) begin
            M_AXI_ARADDR <= 32'h0;
            M_AXI_ARVALID <= 1'b0;
        end
    end

    // Rチャネル用ステートマシン
    parameter S_R_IDLE = 2'b00;
    parameter S_R_READ = 2'b01;

    reg [1:0]   r_state, r_next_state;

    always @ (posedge CLK) begin
        if (RST)
            r_state <= S_R_IDLE;
        else
            r_state <= r_next_state;
    end

    always @* begin
        case (r_state)
            S_R_IDLE:
                if (ar_state == S_AR_ADDR)
                    r_next_state <= S_R_READ;
                else
                    r_next_state <= S_R_IDLE;

            S_R_READ:
                if (M_AXI_RVALID && M_AXI_RLAST)
                    r_next_state <= S_R_IDLE;
                else
                    r_next_state <= S_R_READ;

            default:
                r_next_state <= S_R_IDLE;
        endcase
    end

endmodule

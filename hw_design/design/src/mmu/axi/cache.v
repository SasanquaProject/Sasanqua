module cache_axi
    (
        /* ----- 制御 ----- */
        // クロック, リセット
        input wire          CLK,
        input wire          RST,

        /* ----- メモリアクセス ----- */
        // ヒットチェック
        input wire  [31:0]  HIT_CHECK,
        output wire         HIT_CHECK_RESULT,

        // 読み
        input wire          RDEN,
        input wire  [31:0]  RADDR,
        output reg          RVALID,
        output reg [31:0]   RDATA,

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

    /* ----- キャッシュメモリ ----- */
    reg [19:0]  cached_addr;
    reg [31:0]  cache [0:1024];

    assign HIT_CHECK_RESULT = !RDEN || HIT_CHECK[31:12] == cached_addr;

    always @ (RADDR, cached_addr) begin
        RVALID <= RDEN && RADDR[31:12] == cached_addr;
        RDATA <= RVALID ? cache[RADDR[11:2]] : 32'b0;
    end

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
                if (RDEN && RADDR[31:12] != cached_addr)
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
            M_AXI_ARADDR <= { RADDR[31:12], 12'b0 };
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

    always @ (posedge CLK) begin
        if (RST)
            cached_addr <= 20'hf_ffff;
        else if (ar_state == S_AR_WAIT && ar_next_state == S_AR_IDLE) begin
            cached_addr <= RADDR[31:12];
        end
    end

    // Rチャネル用ステートマシン
    parameter S_R_IDLE = 2'b00;
    parameter S_R_READ = 2'b01;

    reg [1:0]   r_state, r_next_state;
    reg [31:0]  r_rdcnt;

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

    always @ (posedge CLK) begin
        if (RST || ar_state == S_AR_IDLE)
            r_rdcnt <= 32'b0;
        else if (r_state == S_R_READ && M_AXI_RVALID) begin
            r_rdcnt <= r_rdcnt + 32'b1;
            cache[r_rdcnt] <= M_AXI_RDATA;
        end
    end

endmodule

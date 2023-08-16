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
        output wire [31:0]  RDATA,

        // 書き
        input wire          WREN,
        input wire  [31:0]  WADDR,
        input wire  [31:0]  WDATA,

        /* ----- AXIバス ----- */
        // クロック・リセット
        input wire          M_AXI_CLK,
        input wire          M_AXI_RSTN,

        // AWチャネル
        output reg  [31:0]  M_AXI_AWADDR,
        output wire [7:0]   M_AXI_AWLEN,
        output wire [2:0]   M_AXI_AWSIZE,
        output wire [1:0]   M_AXI_AWBURST,
        output reg          M_AXI_AWVALID,
        input  wire         M_AXI_AWREADY,

        // Wチャネル
        output reg  [31:0]  M_AXI_WDATA,
        output wire [3:0]   M_AXI_WSTRB,
        output reg          M_AXI_WLAST,
        output reg          M_AXI_WVALID,
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
    assign M_AXI_AWLEN      = 8'h1f;
    assign M_AXI_AWSIZE     = 3'b010;
    assign M_AXI_AWBURST    = 2'b01;
    assign M_AXI_WSTRB      = 4'b1111;
    assign M_AXI_ARLEN      = 8'h1f;
    assign M_AXI_ARSIZE     = 3'b010;
    assign M_AXI_ARBURST    = 2'b01;

    /* ----- RAM ----- */
    wire        ram_a_rden, ram_a_wren, ram_b_rden, ram_b_wren;
    wire [9:0]  ram_a_raddr, ram_a_waddr, ram_b_raddr, ram_b_waddr;
    wire [31:0] ram_a_rdata, ram_a_wdata, ram_b_rdata, ram_b_wdata;

    ram ram (
        // 制御
        .CLK        (CLK),
        .RST        (RST),

        // アクセスポート
        .A_RDEN     (ram_a_rden),
        .A_RADDR    (ram_a_raddr),
        .A_RDATA    (ram_a_rdata),
        .A_WREN     (ram_a_wren),
        .A_WADDR    (ram_a_waddr),
        .A_WDATA    (ram_a_wdata),
        .B_RDEN     (ram_b_rden),
        .B_RADDR    (ram_b_raddr),
        .B_RDATA    (ram_b_rdata),
        .B_WREN     (ram_b_wren),
        .B_WADDR    (ram_b_waddr),
        .B_WDATA    (ram_b_wdata)
    );

    /* ----- キャッシュ制御 ----- */
    reg         cache_written;
    reg [19:0]  cached_addr;

    assign HIT_CHECK_RESULT = !RDEN || HIT_CHECK[31:12] == cached_addr;

    always @ (posedge CLK) begin
        if (RST) begin
            cache_written <= 1'b0;
            cached_addr <= 20'hf_ffff;
        end
        else if (WREN)
            cache_written <= 1'b1;
        else if (ar_state == S_AR_WAIT && ar_next_state == S_AR_IDLE) begin
            cached_addr <= RIADDR[31:12];
        end
        else if (awb_state == S_AWB_WAIT && awb_next_state == S_AWB_IDLE) begin
            cache_written <= 1'b0;
        end
    end

    /* ----- キャッシュアクセス ----- */
    assign ram_a_rden  = RDEN;
    assign ram_a_raddr = RDEN ? RIADDR[11:2] : ROADDR[11:2];
    assign RDATA       = ram_a_rdata;
    assign ram_a_wren  = WREN;
    assign ram_a_waddr = WADDR[11:2];
    assign ram_a_wdata = WDATA;

    always @ (posedge CLK) begin
        if (RST) begin
            ROADDR <= 32'b0;
            RVALID <= 1'b0;
        end
        else if (STALL) begin
            // do nothing
        end
        else if (RDEN) begin
            ROADDR <= RIADDR;
            RVALID <= RIADDR[31:12] == cached_addr;
        end
        else begin
            RVALID <= 1'b0;
        end
    end

    /* ----- RAMアクセス制御 ------ */
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
                if (RDEN && RIADDR[31:12] != cached_addr && !cache_written)
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

    reg [1:0] r_state, r_next_state;
    reg [9:0] r_cnt;

    assign ram_b_wren  = r_state == S_R_READ && M_AXI_RVALID;
    assign ram_b_waddr = r_cnt;
    assign ram_b_wdata = M_AXI_RDATA;

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
            r_cnt <= 10'b0;
        else if (r_state == S_R_READ && M_AXI_RVALID) begin
            r_cnt <= r_cnt + 10'b1;
        end
    end

    // AW, Bチャネル用ステートマシン
    parameter S_AWB_IDLE    = 2'b00;
    parameter S_AWB_ADDR    = 2'b01;
    parameter S_AWB_WAIT    = 2'b10;

    reg [1:0] awb_state, awb_next_state;

    always @ (posedge CLK) begin
        if (RST)
            awb_state <= S_AWB_IDLE;
        else
            awb_state <= awb_next_state;
    end

    always @* begin
        case (awb_state)
            S_AWB_IDLE:
                if (RDEN && RIADDR[31:12] != cached_addr && cache_written)
                    awb_next_state <= S_AWB_ADDR;
                else
                    awb_next_state <= S_AWB_IDLE;

            S_AWB_ADDR:
                if (M_AXI_AWREADY)
                    awb_next_state <= S_AWB_WAIT;
                else
                    awb_next_state <= S_AWB_ADDR;

            S_AWB_WAIT:
                if (M_AXI_BVALID)
                    if (M_AXI_AWADDR[11:0] == 12'b0)
                        awb_next_state <= S_AWB_IDLE;
                    else
                        awb_next_state <= S_AWB_ADDR;
                else
                    awb_next_state <= S_AWB_WAIT;

            default:
                awb_next_state <= S_AWB_IDLE;
        endcase
    end

    always @ (posedge CLK) begin
        if (RST) begin
            M_AXI_AWADDR <= 32'b0;
            M_AXI_AWVALID <= 1'b0;
        end
        else if (awb_state == S_AWB_IDLE && awb_next_state == S_AWB_ADDR) begin
            M_AXI_AWADDR <= { cached_addr, 12'b0 };
            M_AXI_AWVALID <= 1'b1;
        end
        else if (awb_state == S_AWB_ADDR && awb_next_state == S_AWB_WAIT) begin
            M_AXI_AWADDR <= M_AXI_AWADDR + 32'd128;
            M_AXI_AWVALID <= 1'b0;
        end
        else if (awb_state == S_AWB_WAIT && awb_next_state == S_AWB_ADDR)
            M_AXI_AWVALID <= 1'b1;
    end

    // Wチャネル用ステートマシン
    parameter S_W_IDLE  = 2'b00;
    parameter S_W_WRITE = 2'b01;
    parameter S_W_WAIT  = 2'b11;

    reg [1:0] w_state, w_next_state;
    reg [9:0] w_cnt;

    assign ram_b_rden  = awb_next_state != S_AWB_IDLE;
    assign ram_b_raddr = w_cnt;

    always @ (posedge CLK) begin
        if (RST)
            w_state <= S_W_IDLE;
        else
            w_state <= w_next_state;
    end

    always @* begin
        case (w_state)
            S_W_IDLE:
                if (awb_state == S_AWB_ADDR)
                    w_next_state <= S_W_WAIT;
                else
                    w_next_state <= S_W_IDLE;

            S_W_WAIT:
                if (M_AXI_WREADY && w_cnt[4:0] == 5'b0)
                    w_next_state <= S_W_IDLE;
                else
                    w_next_state <= S_W_WAIT;

            default:
                w_next_state <= S_W_IDLE;
        endcase
    end

    always @ (posedge CLK) begin
        if (RST) begin
            w_cnt <= 10'b0;
            M_AXI_WDATA <= 32'b0;
            M_AXI_WVALID <= 1'b0;
            M_AXI_WLAST <= 1'b0;
        end
        else if (awb_state == S_AWB_IDLE && awb_next_state == S_AWB_ADDR)
            w_cnt <= 10'b0;
        else if (
            (w_state == S_W_IDLE && w_next_state == S_W_WAIT) ||
            (w_next_state == S_W_WAIT && M_AXI_WREADY)
        ) begin
            w_cnt <= w_cnt + 10'b1;
            M_AXI_WDATA <= ram_b_rdata;
            M_AXI_WVALID <= 1'b1;
            M_AXI_WLAST <= w_cnt[4:0] == 5'h1f;
        end
        else if (w_state == S_W_WAIT && w_next_state == S_W_IDLE) begin
            M_AXI_WVALID <= 1'b0;
            M_AXI_WLAST <= 1'b0;
        end
    end

endmodule

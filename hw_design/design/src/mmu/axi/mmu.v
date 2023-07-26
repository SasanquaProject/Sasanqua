module mmu_axi
    (
        /* ----- 制御 ----- */
        // クロック, リセット
        input wire          CLK,
        input wire          RST,

        // パイプライン制御
        output wire         MEM_WAIT,

        /* ----- メモリアクセス信号 ----- */
        // 命令 (優先度 高)
        input wire          INST_RDEN,
        input wire  [31:0]  INST_RADDR,
        output wire         INST_RVALID,
        output wire [31:0]  INST_RDATA,

        // データ (優先度 低)
        // input wire          DATA_WREN,
        // input wire [31:0]   DATA_WRADDR,
        // input wire [31:0]   DATA_WRDATA,
        input wire          DATA_RDEN,
        input wire  [31:0]  DATA_RADDR,
        output wire         DATA_RVALID,
        output wire [31:0]  DATA_RDATA,

        /* ----- AXIバス ----- */
        // クロック・リセット
        input wire          M_AXI_CLK,
        input wire          M_AXI_RSTN,

        // AWチャネル
        output wire         M_AXI_AWID,
        output wire [31:0]  M_AXI_AWADDR,
        output wire [7:0]   M_AXI_AWLEN,
        output wire [2:0]   M_AXI_AWSIZE,
        output wire [1:0]   M_AXI_AWBURST,
        output wire [1:0]   M_AXI_AWLOCK,
        output wire [3:0]   M_AXI_AWCACHE,
        output wire [2:0]   M_AXI_AWPROT,
        output wire [3:0]   M_AXI_AWQOS,
        output wire         M_AXI_AWUSER,
        output wire         M_AXI_AWVALID,
        input  wire         M_AXI_AWREADY,

        // Wチャネル
        output wire [31:0]  M_AXI_WDATA,
        output wire [3:0]   M_AXI_WSTRB,
        output wire         M_AXI_WLAST,
        output wire         M_AXI_WUSER,
        output wire         M_AXI_WVALID,
        input  wire         M_AXI_WREADY,

        // Bチャネル
        input  wire         M_AXI_BID,
        input  wire [1:0]   M_AXI_BRESP,
        input  wire         M_AXI_BUSER,
        input  wire         M_AXI_BVALID,
        output wire         M_AXI_BREADY,

        // ARチャネル
        output wire         M_AXI_ARID,
        output wire [31:0]  M_AXI_ARADDR,
        output wire [7:0]   M_AXI_ARLEN,
        output wire [2:0]   M_AXI_ARSIZE,
        output wire [1:0]   M_AXI_ARBURST,
        output wire [1:0]   M_AXI_ARLOCK,
        output wire [3:0]   M_AXI_ARCACHE,
        output wire [2:0]   M_AXI_ARPROT,
        output wire [3:0]   M_AXI_ARQOS,
        output wire         M_AXI_ARUSER,
        output wire         M_AXI_ARVALID,
        input  wire         M_AXI_ARREADY,

        // Rチャネル
        input  wire         M_AXI_RID,
        input  wire [31:0]  M_AXI_RDATA,
        input  wire [1:0]   M_AXI_RRESP,
        input  wire         M_AXI_RLAST,
        input  wire         M_AXI_RUSER,
        input  wire         M_AXI_RVALID,
        output wire         M_AXI_RREADY
    );

    assign MEM_WAIT = !exists_inst_cache;

    /* ----- AXIバス設定 ----- */
    assign M_AXI_AWID       = 'b0;
    assign M_AXI_AWLOCK     = 2'b00;
    assign M_AXI_AWCACHE    = 4'b0011;
    assign M_AXI_AWPROT     = 3'h0;
    assign M_AXI_AWQOS      = 4'h0;
    assign M_AXI_AWUSER     = 'b0;
    assign M_AXI_WUSER      = 'b0;
    assign M_AXI_BREADY     = 1'b1;
    assign M_AXI_ARID       = 'b0;
    assign M_AXI_ARLOCK     = 1'b0;
    assign M_AXI_ARCACHE    = 4'b0011;
    assign M_AXI_ARPROT     = 3'h0;
    assign M_AXI_ARQOS      = 4'h0;
    assign M_AXI_ARUSER     = 'b0;
    assign M_AXI_RREADY     = 1'b1;

    /* ----- キャッシュメモリ ----- */
    // AXIバス配線
    assign M_AXI_AWADDR     = m_axi_inst_awaddr | m_axi_data_awaddr;
    assign M_AXI_AWLEN      = m_axi_inst_awlen | m_axi_data_awlen;
    assign M_AXI_AWSIZE     = m_axi_inst_awsize | m_axi_data_awsize;
    assign M_AXI_AWBURST    = m_axi_inst_awburst | m_axi_data_awburst;
    assign M_AXI_AWVALID    = m_axi_inst_awvalid | m_axi_data_awvalid;
    assign M_AXI_WDATA      = m_axi_inst_wdata | m_axi_data_wdata;
    assign M_AXI_WSTRB      = m_axi_inst_wstrb | m_axi_data_wstrb;
    assign M_AXI_WLAST      = m_axi_inst_wlast | m_axi_data_wlast;
    assign M_AXI_WVALID     = m_axi_inst_wvalid | m_axi_data_wvalid;
    assign M_AXI_ARADDR     = m_axi_inst_araddr | m_axi_data_araddr;
    assign M_AXI_ARLEN      = m_axi_inst_arlen | m_axi_data_arlen;
    assign M_AXI_ARSIZE     = m_axi_inst_arsize | m_axi_data_arsize;
    assign M_AXI_ARBURST    = m_axi_inst_arburst | m_axi_data_arburst;
    assign M_AXI_ARVALID    = m_axi_inst_arvalid | m_axi_data_arvalid;

    // 命令キャッシュ
    wire        exists_inst_cache;

    wire [31:0] m_axi_inst_awaddr, m_axi_inst_wdata, m_axi_inst_araddr;
    wire [7:0]  m_axi_inst_awlen, m_axi_inst_arlen;
    wire [3:0]  m_axi_inst_wstrb;
    wire [2:0]  m_axi_inst_awsize, m_axi_inst_arsize;
    wire [1:0]  m_axi_inst_awburst, m_axi_inst_arburst;
    wire        m_axi_inst_awvalid, m_axi_inst_wlast, m_axi_inst_wvalid;
    wire        m_axi_inst_arvalid;

    cache_axi inst_cache (
        // 制御
        .CLK                (CLK),
        .RST                (RST),

        // メモリアクセス
        .HIT_CHECK          (INST_RADDR),
        .HIT_CHECK_RESULT   (exists_inst_cache),
        .RDEN               (INST_RDEN),
        .RADDR              (INST_RADDR),
        .RVALID             (INST_RVALID),
        .RDATA              (INST_RDATA),

        // AXIバス
        .M_AXI_AWADDR       (m_axi_inst_awaddr),
        .M_AXI_AWLEN        (m_axi_inst_awlen),
        .M_AXI_AWSIZE       (m_axi_inst_awsize),
        .M_AXI_AWBURST      (m_axi_inst_awburst),
        .M_AXI_AWVALID      (m_axi_inst_awvalid),
        .M_AXI_AWREADY      (M_AXI_AWREADY),
        .M_AXI_WDATA        (m_axi_inst_wdata),
        .M_AXI_WSTRB        (m_axi_inst_wstrb),
        .M_AXI_WLAST        (m_axi_inst_wlast),
        .M_AXI_WVALID       (m_axi_inst_wvalid),
        .M_AXI_WREADY       (M_AXI_WREADY),
        .M_AXI_BID          (M_AXI_BID),
        .M_AXI_BRESP        (M_AXI_BRESP),
        .M_AXI_BVALID       (M_AXI_BVALID),
        .M_AXI_ARADDR       (m_axi_inst_araddr),
        .M_AXI_ARLEN        (m_axi_inst_arlen),
        .M_AXI_ARSIZE       (m_axi_inst_arsize),
        .M_AXI_ARBURST      (m_axi_inst_arburst),
        .M_AXI_ARVALID      (m_axi_inst_arvalid),
        .M_AXI_ARREADY      (M_AXI_ARREADY),
        .M_AXI_RID          (M_AXI_RID),
        .M_AXI_RDATA        (M_AXI_RDATA),
        .M_AXI_RRESP        (M_AXI_RRESP),
        .M_AXI_RLAST        (M_AXI_RLAST),
        .M_AXI_RVALID       (M_AXI_RVALID)
    );

    // データキャッシュ
    wire exists_data_cache;

    wire [31:0] m_axi_data_awaddr, m_axi_data_wdata, m_axi_data_araddr;
    wire [7:0]  m_axi_data_awlen, m_axi_data_arlen;
    wire [3:0]  m_axi_data_wstrb;
    wire [2:0]  m_axi_data_awsize, m_axi_data_arsize;
    wire [1:0]  m_axi_data_awburst, m_axi_data_arburst;
    wire        m_axi_data_awvalid, m_axi_data_wlast, m_axi_data_wvalid;
    wire        m_axi_data_arvalid;

    cache_axi data_cache (
        // 制御
        .CLK                (CLK),
        .RST                (RST),

        // メモリアクセス
        .HIT_CHECK          (data_RADDR),
        .HIT_CHECK_RESULT   (exists_data_cache),
        .RDEN               (data_RDEN),
        .RADDR              (data_RADDR),
        .RVALID             (data_RVALID),
        .RDATA              (data_RDATA),

        // AXIバス
        .M_AXI_AWADDR       (m_axi_data_awaddr),
        .M_AXI_AWLEN        (m_axi_data_awlen),
        .M_AXI_AWSIZE       (m_axi_data_awsize),
        .M_AXI_AWBURST      (m_axi_data_awburst),
        .M_AXI_AWVALID      (m_axi_data_awvalid),
        .M_AXI_AWREADY      (M_AXI_AWREADY),
        .M_AXI_WDATA        (m_axi_data_wdata),
        .M_AXI_WSTRB        (m_axi_data_wstrb),
        .M_AXI_WLAST        (m_axi_data_wlast),
        .M_AXI_WVALID       (m_axi_data_wvalid),
        .M_AXI_WREADY       (M_AXI_WREADY),
        .M_AXI_BID          (M_AXI_BID),
        .M_AXI_BRESP        (M_AXI_BRESP),
        .M_AXI_BVALID       (M_AXI_BVALID),
        .M_AXI_ARADDR       (m_axi_data_araddr),
        .M_AXI_ARLEN        (m_axi_data_arlen),
        .M_AXI_ARSIZE       (m_axi_data_arsize),
        .M_AXI_ARBURST      (m_axi_data_arburst),
        .M_AXI_ARVALID      (m_axi_data_arvalid),
        .M_AXI_ARREADY      (M_AXI_ARREADY),
        .M_AXI_RID          (M_AXI_RID),
        .M_AXI_RDATA        (M_AXI_RDATA),
        .M_AXI_RRESP        (M_AXI_RRESP),
        .M_AXI_RLAST        (M_AXI_RLAST),
        .M_AXI_RVALID       (M_AXI_RVALID)
    );

endmodule
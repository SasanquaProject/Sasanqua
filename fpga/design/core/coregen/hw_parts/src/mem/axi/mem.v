module mem_axi
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
        input wire  [31:0]  INST_RIADDR,
        output wire [31:0]  INST_ROADDR,
        output wire         INST_RVALID,
        output wire [31:0]  INST_RDATA,

        // データ (優先度 低)
        input wire          DATA_RDEN,
        input wire  [31:0]  DATA_RIADDR,
        output wire [31:0]  DATA_ROADDR,
        output wire         DATA_RVALID,
        output wire [31:0]  DATA_RDATA,
        input wire          DATA_WREN,
        input wire  [3:0]   DATA_WSTRB,
        input wire  [31:0]  DATA_WADDR,
        input wire  [31:0]  DATA_WDATA,

        /* ----- AXIバス ----- */
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

    assign MEM_WAIT    = !exists_inst_cache || !exists_data_cache || device_loading;
    assign INST_ROADDR = inst_rvalid ? inst_roaddr : rom_inst_roaddr;
    assign INST_RVALID = inst_rvalid ? inst_rvalid : rom_inst_rvalid;
    assign INST_RDATA  = inst_rvalid ? inst_rdata : rom_inst_rdata;
    assign DATA_ROADDR = data_rvalid   ? data_roaddr :
                         device_rvalid ? device_roaddr :
                                         rom_data_roaddr;
    assign DATA_RVALID = data_rvalid   ? data_rvalid :
                         device_rvalid ? device_rvalid :
                                         rom_data_rvalid;
    assign DATA_RDATA  = data_rvalid   ? data_rdata :
                         device_rvalid ? device_rdata :
                                         rom_data_rdata;

    /* ----- AXIバス制御 ----- */
    interconnect_axi interconnect_axi (
        // 制御
        .CLK                (CLK),
        .RST                (RST),

        // AXIバス
        .M_AXI_AWID         (M_AXI_AWID),
        .M_AXI_AWADDR       (M_AXI_AWADDR),
        .M_AXI_AWLEN        (M_AXI_AWLEN),
        .M_AXI_AWSIZE       (M_AXI_AWSIZE),
        .M_AXI_AWBURST      (M_AXI_AWBURST),
        .M_AXI_AWLOCK       (M_AXI_AWLOCK),
        .M_AXI_AWCACHE      (M_AXI_AWCACHE),
        .M_AXI_AWPROT       (M_AXI_AWPROT),
        .M_AXI_AWQOS        (M_AXI_AWQOS),
        .M_AXI_AWUSER       (M_AXI_AWUSER),
        .M_AXI_AWVALID      (M_AXI_AWVALID),
        .M_AXI_AWREADY      (M_AXI_AWREADY),
        .M_AXI_WDATA        (M_AXI_WDATA),
        .M_AXI_WSTRB        (M_AXI_WSTRB),
        .M_AXI_WLAST        (M_AXI_WLAST),
        .M_AXI_WUSER        (M_AXI_WUSER),
        .M_AXI_WVALID       (M_AXI_WVALID),
        .M_AXI_WREADY       (M_AXI_WREADY),
        .M_AXI_BID          (M_AXI_BID),
        .M_AXI_BRESP        (M_AXI_BRESP),
        .M_AXI_BUSER        (M_AXI_BUSER),
        .M_AXI_BVALID       (M_AXI_BVALID),
        .M_AXI_BREADY       (M_AXI_BREADY),
        .M_AXI_ARID         (M_AXI_ARID),
        .M_AXI_ARADDR       (M_AXI_ARADDR),
        .M_AXI_ARLEN        (M_AXI_ARLEN),
        .M_AXI_ARSIZE       (M_AXI_ARSIZE),
        .M_AXI_ARBURST      (M_AXI_ARBURST),
        .M_AXI_ARLOCK       (M_AXI_ARLOCK),
        .M_AXI_ARCACHE      (M_AXI_ARCACHE),
        .M_AXI_ARPROT       (M_AXI_ARPROT),
        .M_AXI_ARQOS        (M_AXI_ARQOS),
        .M_AXI_ARUSER       (M_AXI_ARUSER),
        .M_AXI_ARVALID      (M_AXI_ARVALID),
        .M_AXI_ARREADY      (M_AXI_ARREADY),
        .M_AXI_RID          (M_AXI_RID),
        .M_AXI_RDATA        (M_AXI_RDATA),
        .M_AXI_RRESP        (M_AXI_RRESP),
        .M_AXI_RLAST        (M_AXI_RLAST),
        .M_AXI_RUSER        (M_AXI_RUSER),
        .M_AXI_RVALID       (M_AXI_RVALID),
        .M_AXI_RREADY       (M_AXI_RREADY),

        .S1_AXI_AWADDR      (axi_inst_awaddr),
        .S1_AXI_AWLEN       (axi_inst_awlen),
        .S1_AXI_AWSIZE      (axi_inst_awsize),
        .S1_AXI_AWBURST     (axi_inst_awburst),
        .S1_AXI_AWVALID     (axi_inst_awvalid),
        .S1_AXI_AWREADY     (axi_inst_awready),
        .S1_AXI_WDATA       (axi_inst_wdata),
        .S1_AXI_WSTRB       (axi_inst_wstrb),
        .S1_AXI_WLAST       (axi_inst_wlast),
        .S1_AXI_WVALID      (axi_inst_wvalid),
        .S1_AXI_WREADY      (axi_inst_wready),
        .S1_AXI_BID         (axi_inst_bid),
        .S1_AXI_BRESP       (axi_inst_bresp),
        .S1_AXI_BVALID      (axi_inst_bvalid),
        .S1_AXI_ARADDR      (axi_inst_araddr),
        .S1_AXI_ARLEN       (axi_inst_arlen),
        .S1_AXI_ARSIZE      (axi_inst_arsize),
        .S1_AXI_ARBURST     (axi_inst_arburst),
        .S1_AXI_ARVALID     (axi_inst_arvalid),
        .S1_AXI_ARREADY     (axi_inst_arready),
        .S1_AXI_RID         (axi_inst_rid),
        .S1_AXI_RDATA       (axi_inst_rdata),
        .S1_AXI_RRESP       (axi_inst_rresp),
        .S1_AXI_RLAST       (axi_inst_rlast),
        .S1_AXI_RVALID      (axi_inst_rvalid),

        .S2_AXI_AWADDR      (axi_data_awaddr),
        .S2_AXI_AWLEN       (axi_data_awlen),
        .S2_AXI_AWSIZE      (axi_data_awsize),
        .S2_AXI_AWBURST     (axi_data_awburst),
        .S2_AXI_AWVALID     (axi_data_awvalid),
        .S2_AXI_AWREADY     (axi_data_awready),
        .S2_AXI_WDATA       (axi_data_wdata),
        .S2_AXI_WSTRB       (axi_data_wstrb),
        .S2_AXI_WLAST       (axi_data_wlast),
        .S2_AXI_WVALID      (axi_data_wvalid),
        .S2_AXI_WREADY      (axi_data_wready),
        .S2_AXI_BID         (axi_data_bid),
        .S2_AXI_BRESP       (axi_data_bresp),
        .S2_AXI_BVALID      (axi_data_bvalid),
        .S2_AXI_ARADDR      (axi_data_araddr),
        .S2_AXI_ARLEN       (axi_data_arlen),
        .S2_AXI_ARSIZE      (axi_data_arsize),
        .S2_AXI_ARBURST     (axi_data_arburst),
        .S2_AXI_ARVALID     (axi_data_arvalid),
        .S2_AXI_ARREADY     (axi_data_arready),
        .S2_AXI_RID         (axi_data_rid),
        .S2_AXI_RDATA       (axi_data_rdata),
        .S2_AXI_RRESP       (axi_data_rresp),
        .S2_AXI_RLAST       (axi_data_rlast),
        .S2_AXI_RVALID      (axi_data_rvalid),

        .S3_AXI_AWADDR      (axi_device_awaddr),
        .S3_AXI_AWLEN       (axi_device_awlen),
        .S3_AXI_AWSIZE      (axi_device_awsize),
        .S3_AXI_AWBURST     (axi_device_awburst),
        .S3_AXI_AWVALID     (axi_device_awvalid),
        .S3_AXI_AWREADY     (axi_device_awready),
        .S3_AXI_WDATA       (axi_device_wdata),
        .S3_AXI_WSTRB       (axi_device_wstrb),
        .S3_AXI_WLAST       (axi_device_wlast),
        .S3_AXI_WVALID      (axi_device_wvalid),
        .S3_AXI_WREADY      (axi_device_wready),
        .S3_AXI_BID         (axi_device_bid),
        .S3_AXI_BRESP       (axi_device_bresp),
        .S3_AXI_BVALID      (axi_device_bvalid),
        .S3_AXI_ARADDR      (axi_device_araddr),
        .S3_AXI_ARLEN       (axi_device_arlen),
        .S3_AXI_ARSIZE      (axi_device_arsize),
        .S3_AXI_ARBURST     (axi_device_arburst),
        .S3_AXI_ARVALID     (axi_device_arvalid),
        .S3_AXI_ARREADY     (axi_device_arready),
        .S3_AXI_RID         (axi_device_rid),
        .S3_AXI_RDATA       (axi_device_rdata),
        .S3_AXI_RRESP       (axi_device_rresp),
        .S3_AXI_RLAST       (axi_device_rlast),
        .S3_AXI_RVALID      (axi_device_rvalid)
    );

    /* ----- アクセス振り分け ----- */
    wire [2:0] inst_rselect, data_rselect, data_wselect;

    assign inst_rselect = access_direction(INST_RIADDR);
    assign data_rselect = access_direction(DATA_RIADDR);
    assign data_wselect = access_direction(DATA_WADDR);

    function [2:0] access_direction;
        input [31:0] ADDR;

        if      (ADDR[31:12] == 20'b0) access_direction = 3'b001; // 0x0000_0000 ~ 0x0000_0fff : ROM
        else if (ADDR[31:29] ==  3'd0) access_direction = 3'b000; // 0x0000_1000 ~ 0x1fff_ffff : On-chip peripherals
        else if (ADDR[31:30] ==  2'd0) access_direction = 3'b010; // 0x2000_0000 ~ 0x3fff_ffff : RAM
        else if (ADDR[31]    ==  1'd0) access_direction = 3'b100; // 0x4000_0000 ~ 0x7fff_ffff : Other peripherals
        else                           access_direction = 3'b000; // 0x8000_0000 ~ 0xffff_ffff : (Reserved);
    endfunction

    /* ----- ROM ----- */
    wire [31:0] rom_inst_roaddr, rom_inst_rdata, rom_data_roaddr, rom_data_rdata;
    wire [9:0]  rom_inst_roaddr_10, rom_data_roaddr_10;
    wire        rom_inst_rvalid, rom_data_rvalid;

    assign rom_inst_roaddr = { 20'b0, rom_inst_roaddr_10, 2'b0 };
    assign rom_data_roaddr = { 20'b0, rom_data_roaddr_10, 2'b0 };

    rom_dualport # (
        .ADDR_WIDTH         (10),   // => SIZE: 1024
        .DATA_WIDTH_2POW    (0)     // => WIDTH: 32bit
    ) rom_dualport (
        // 制御
        .CLK                (CLK),
        .RST                (RST),

        // アクセスポート
        .A_SELECT           (inst_rselect[0]),
        .A_RDEN             (INST_RDEN),
        .A_RIADDR           (INST_RIADDR),
        .A_ROADDR           (rom_inst_roaddr_10),
        .A_RVALID           (rom_inst_rvalid),
        .A_RDATA            (rom_inst_rdata),
        .B_SELECT           (data_rselect[0]),
        .B_RDEN             (DATA_RDEN),
        .B_RIADDR           (DATA_RIADDR),
        .B_ROADDR           (rom_data_roaddr_10),
        .B_RVALID           (rom_data_rvalid),
        .B_RDATA            (rom_data_rdata)
    );

    /* ----- キャッシュメモリ ----- */
    // 命令キャッシュ
    wire [31:0] axi_inst_awaddr, axi_inst_wdata, axi_inst_araddr, axi_inst_rdata;
    wire [7:0]  axi_inst_awlen, axi_inst_arlen;
    wire [3:0]  axi_inst_wstrb;
    wire [2:0]  axi_inst_awsize, axi_inst_arsize;
    wire [1:0]  axi_inst_awburst, axi_inst_bresp, axi_inst_arburst, axi_inst_rresp;
    wire        axi_inst_awvalid, axi_inst_awready, axi_inst_wlast, axi_inst_wvalid, axi_inst_wready;
    wire        axi_inst_bid, axi_inst_bvalid;
    wire        axi_inst_arvalid, axi_inst_arready, axi_inst_rid, axi_inst_rlast, axi_inst_rvalid;

    wire        exists_inst_cache, inst_rvalid, dummy_wselect, dummy_wren;
    wire [3:0]  dummy_wstrb;
    wire [31:0] inst_roaddr, inst_rdata, dummy_waddr, dummy_wdata;

    assign dummy_wselect = 1'b0;
    assign dummy_wren    = 1'b0;
    assign dummy_wstrb   = 4'b0;
    assign dummy_waddr   = 32'b0;
    assign dummy_wdata   = 32'b0;

    cache_axi # (
        .PAGES              (1),    // => SIZE: 4kb x 1
        .DATA_WIDTH_2POW    (0)     // => WIDTH: 32bit
    ) inst_cache (
        // 制御
        .CLK                (CLK),
        .RST                (RST),
        .STALL              (MEM_WAIT),

        // メモリアクセス
        .HIT_CHECK_RESULT   (exists_inst_cache),
        .RSELECT            (inst_rselect[1]),
        .RDEN               (INST_RDEN),
        .RIADDR             (INST_RIADDR),
        .ROADDR             (inst_roaddr),
        .RVALID             (inst_rvalid),
        .RDATA              (inst_rdata),
        .WSELECT            (dummy_wselect),
        .WREN               (dummy_wren),
        .WSTRB              (dummy_wstrb),
        .WADDR              (dummy_waddr),
        .WDATA              (dummy_wdata),

        // AXIバス
        .M_AXI_AWADDR       (axi_inst_awaddr),
        .M_AXI_AWLEN        (axi_inst_awlen),
        .M_AXI_AWSIZE       (axi_inst_awsize),
        .M_AXI_AWBURST      (axi_inst_awburst),
        .M_AXI_AWVALID      (axi_inst_awvalid),
        .M_AXI_AWREADY      (axi_inst_awready),
        .M_AXI_WDATA        (axi_inst_wdata),
        .M_AXI_WSTRB        (axi_inst_wstrb),
        .M_AXI_WLAST        (axi_inst_wlast),
        .M_AXI_WVALID       (axi_inst_wvalid),
        .M_AXI_WREADY       (axi_inst_wready),
        .M_AXI_BID          (axi_inst_bid),
        .M_AXI_BRESP        (axi_inst_bresp),
        .M_AXI_BVALID       (axi_inst_bvalid),
        .M_AXI_ARADDR       (axi_inst_araddr),
        .M_AXI_ARLEN        (axi_inst_arlen),
        .M_AXI_ARSIZE       (axi_inst_arsize),
        .M_AXI_ARBURST      (axi_inst_arburst),
        .M_AXI_ARVALID      (axi_inst_arvalid),
        .M_AXI_ARREADY      (axi_inst_arready),
        .M_AXI_RID          (axi_inst_rid),
        .M_AXI_RDATA        (axi_inst_rdata),
        .M_AXI_RRESP        (axi_inst_rresp),
        .M_AXI_RLAST        (axi_inst_rlast),
        .M_AXI_RVALID       (axi_inst_rvalid)
    );

    // データキャッシュ
    wire [31:0] axi_data_awaddr, axi_data_wdata, axi_data_araddr, axi_data_rdata;
    wire [7:0]  axi_data_awlen, axi_data_arlen;
    wire [3:0]  axi_data_wstrb;
    wire [2:0]  axi_data_awsize, axi_data_arsize;
    wire [1:0]  axi_data_awburst, axi_data_bresp, axi_data_arburst, axi_data_rresp;
    wire        axi_data_awvalid, axi_data_awready, axi_data_wlast, axi_data_wvalid, axi_data_wready;
    wire        axi_data_bid, axi_data_bvalid;
    wire        axi_data_arvalid, axi_data_arready, axi_data_rid, axi_data_rlast, axi_data_rvalid;

    wire [31:0] data_roaddr, data_rdata;
    wire        exists_data_cache, data_rvalid;

    cache_axi # (
        .PAGES              (1),    // => SIZE: 4kb x 1
        .DATA_WIDTH_2POW    (0)     // => WIDTH: 32bit
    ) data_cache (
        // 制御
        .CLK                (CLK),
        .RST                (RST),
        .STALL              (MEM_WAIT),

        // メモリアクセス
        .HIT_CHECK_RESULT   (exists_data_cache),
        .RSELECT            (data_rselect[1]),
        .RDEN               (DATA_RDEN),
        .RIADDR             (DATA_RIADDR),
        .ROADDR             (data_roaddr),
        .RVALID             (data_rvalid),
        .RDATA              (data_rdata),
        .WSELECT            (data_wselect[1]),
        .WREN               (DATA_WREN),
        .WSTRB              (DATA_WSTRB),
        .WADDR              (DATA_WADDR),
        .WDATA              (DATA_WDATA),

        // AXIバス
        .M_AXI_AWADDR       (axi_data_awaddr),
        .M_AXI_AWLEN        (axi_data_awlen),
        .M_AXI_AWSIZE       (axi_data_awsize),
        .M_AXI_AWBURST      (axi_data_awburst),
        .M_AXI_AWVALID      (axi_data_awvalid),
        .M_AXI_AWREADY      (axi_data_awready),
        .M_AXI_WDATA        (axi_data_wdata),
        .M_AXI_WSTRB        (axi_data_wstrb),
        .M_AXI_WLAST        (axi_data_wlast),
        .M_AXI_WVALID       (axi_data_wvalid),
        .M_AXI_WREADY       (axi_data_wready),
        .M_AXI_BID          (axi_data_bid),
        .M_AXI_BRESP        (axi_data_bresp),
        .M_AXI_BVALID       (axi_data_bvalid),
        .M_AXI_ARADDR       (axi_data_araddr),
        .M_AXI_ARLEN        (axi_data_arlen),
        .M_AXI_ARSIZE       (axi_data_arsize),
        .M_AXI_ARBURST      (axi_data_arburst),
        .M_AXI_ARVALID      (axi_data_arvalid),
        .M_AXI_ARREADY      (axi_data_arready),
        .M_AXI_RID          (axi_data_rid),
        .M_AXI_RDATA        (axi_data_rdata),
        .M_AXI_RRESP        (axi_data_rresp),
        .M_AXI_RLAST        (axi_data_rlast),
        .M_AXI_RVALID       (axi_data_rvalid)
    );

    /* ----- 外部デバイス ----- */
    wire [31:0] axi_device_awaddr, axi_device_wdata, axi_device_araddr, axi_device_rdata;
    wire [7:0]  axi_device_awlen, axi_device_arlen;
    wire [3:0]  axi_device_wstrb;
    wire [2:0]  axi_device_awsize, axi_device_arsize;
    wire [1:0]  axi_device_awburst, axi_device_bresp, axi_device_arburst, axi_device_rresp;
    wire        axi_device_awvalid, axi_device_awready, axi_device_wlast, axi_device_wvalid, axi_device_wready;
    wire        axi_device_bid, axi_device_bvalid;
    wire        axi_device_arvalid, axi_device_arready, axi_device_rid, axi_device_rlast, axi_device_rvalid;

    wire [31:0] device_roaddr, device_rdata;
    wire        device_loading, device_rvalid;

    translate_axi translate_axi (
        // 制御
        .CLK                (CLK),
        .RST                (RST),
        .STALL              (MEM_WAIT),
        .LOADING            (device_loading),

        // メモリアクセス
        .RSELECT            (data_rselect[2]),
        .RDEN               (DATA_RDEN),
        .RIADDR             (DATA_RIADDR),
        .ROADDR             (device_roaddr),
        .RVALID             (device_rvalid),
        .RDATA              (device_rdata),
        .WSELECT            (data_wselect[2]),
        .WREN               (DATA_WREN),
        .WSTRB              (DATA_WSTRB),
        .WADDR              (DATA_WADDR),
        .WDATA              (DATA_WDATA),

        // AXIバス
        .M_AXI_AWADDR       (axi_device_awaddr),
        .M_AXI_AWLEN        (axi_device_awlen),
        .M_AXI_AWSIZE       (axi_device_awsize),
        .M_AXI_AWBURST      (axi_device_awburst),
        .M_AXI_AWVALID      (axi_device_awvalid),
        .M_AXI_AWREADY      (axi_device_awready),
        .M_AXI_WDATA        (axi_device_wdata),
        .M_AXI_WSTRB        (axi_device_wstrb),
        .M_AXI_WLAST        (axi_device_wlast),
        .M_AXI_WVALID       (axi_device_wvalid),
        .M_AXI_WREADY       (axi_device_wready),
        .M_AXI_BID          (axi_device_bid),
        .M_AXI_BRESP        (axi_device_bresp),
        .M_AXI_BVALID       (axi_device_bvalid),
        .M_AXI_ARADDR       (axi_device_araddr),
        .M_AXI_ARLEN        (axi_device_arlen),
        .M_AXI_ARSIZE       (axi_device_arsize),
        .M_AXI_ARBURST      (axi_device_arburst),
        .M_AXI_ARVALID      (axi_device_arvalid),
        .M_AXI_ARREADY      (axi_device_arready),
        .M_AXI_RID          (axi_device_rid),
        .M_AXI_RDATA        (axi_device_rdata),
        .M_AXI_RRESP        (axi_device_rresp),
        .M_AXI_RLAST        (axi_device_rlast),
        .M_AXI_RVALID       (axi_device_rvalid)
    );

endmodule

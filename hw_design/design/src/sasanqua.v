module sasanqua
    (
        /* ----- 制御 ------ */
        input   wire        CLK,
        input   wire        RST,

        /* ----- 状態 ----- */
        output  wire [31:0] STAT,

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

    assign STAT = 32'd1204;

    /* ----- MMU ----- */
    reg         inst_rden, data_rden;
    reg  [31:0] inst_raddr, data_raddr;
    wire        mem_wait, inst_rvalid, data_rvalid;
    wire [31:0] inst_rdata, data_rdata;

    always @ (posedge CLK) begin
        if (RST) begin
            inst_rden <= 1'b0;
            inst_raddr <= 32'hffff_fffc;
        end
        else if (!mem_wait) begin
            inst_rden <= 1'b1;
            inst_raddr <= inst_raddr + 32'd4;
        end
    end

    always @ (posedge CLK) begin
        data_rden <= 1'b0;
        data_raddr <= 32'b0;
    end

    mmu_axi mmu (
        // 制御
        .CLK            (CLK),
        .RST            (RST),
        .MEM_WAIT       (mem_wait),

        // メモリアクセス
        .INST_RDEN      (inst_rden),
        .INST_RADDR     (inst_raddr),
        .INST_RVALID    (inst_rvalid),
        .INST_RDATA     (inst_rdata),
        .DATA_RDEN      (data_rden),
        .DATA_RADDR     (data_raddr),
        .DATA_RVALID    (data_rvalid),
        .DATA_RDATA     (data_rdata),

        // AXIバス
        .M_AXI_CLK      (M_AXI_CLK),
        .M_AXI_RSTN     (M_AXI_RSTN),
        .M_AXI_AWID     (M_AXI_AWID),
        .M_AXI_AWADDR   (M_AXI_AWADDR),
        .M_AXI_AWLEN    (M_AXI_AWLEN),
        .M_AXI_AWSIZE   (M_AXI_AWSIZE),
        .M_AXI_AWBURST  (M_AXI_AWBURST),
        .M_AXI_AWLOCK   (M_AXI_AWLOCK),
        .M_AXI_AWCACHE  (M_AXI_AWCACHE),
        .M_AXI_AWPROT   (M_AXI_AWPROT),
        .M_AXI_AWQOS    (M_AXI_AWQOS),
        .M_AXI_AWUSER   (M_AXI_AWUSER),
        .M_AXI_AWVALID  (M_AXI_AWVALID),
        .M_AXI_AWREADY  (M_AXI_AWREADY),
        .M_AXI_WDATA    (M_AXI_WDATA),
        .M_AXI_WSTRB    (M_AXI_WSTRB),
        .M_AXI_WLAST    (M_AXI_WLAST),
        .M_AXI_WUSER    (M_AXI_WUSER),
        .M_AXI_WVALID   (M_AXI_WVALID),
        .M_AXI_WREADY   (M_AXI_WREADY),
        .M_AXI_BID      (M_AXI_BID),
        .M_AXI_BRESP    (M_AXI_BRESP),
        .M_AXI_BUSER    (M_AXI_BUSER),
        .M_AXI_BVALID   (M_AXI_BVALID),
        .M_AXI_BREADY   (M_AXI_BREADY),
        .M_AXI_ARID     (M_AXI_ARID),
        .M_AXI_ARADDR   (M_AXI_ARADDR),
        .M_AXI_ARLEN    (M_AXI_ARLEN),
        .M_AXI_ARSIZE   (M_AXI_ARSIZE),
        .M_AXI_ARBURST  (M_AXI_ARBURST),
        .M_AXI_ARLOCK   (M_AXI_ARLOCK),
        .M_AXI_ARCACHE  (M_AXI_ARCACHE),
        .M_AXI_ARPROT   (M_AXI_ARPROT),
        .M_AXI_ARQOS    (M_AXI_ARQOS),
        .M_AXI_ARUSER   (M_AXI_ARUSER),
        .M_AXI_ARVALID  (M_AXI_ARVALID),
        .M_AXI_ARREADY  (M_AXI_ARREADY),
        .M_AXI_RID      (M_AXI_RID),
        .M_AXI_RDATA    (M_AXI_RDATA),
        .M_AXI_RRESP    (M_AXI_RRESP),
        .M_AXI_RLAST    (M_AXI_RLAST),
        .M_AXI_RUSER    (M_AXI_RUSER),
        .M_AXI_RVALID   (M_AXI_RVALID),
        .M_AXI_RREADY   (M_AXI_RREADY)
    );

endmodule

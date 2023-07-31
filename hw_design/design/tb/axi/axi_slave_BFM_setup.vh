/* ----- バス用リセット信号 ----- */
wire                            RSTN = ~RST;

/* ----- AXIバス接続用 ----- */
// AWチャネル
wire                            M_AXI_AWID;
wire [31:0]                     M_AXI_AWADDR;
wire [7:0]                      M_AXI_AWLEN;
wire [2:0]                      M_AXI_AWSIZE;
wire [1:0]                      M_AXI_AWBURST;
wire [1:0]                      M_AXI_AWLOCK;
wire [3:0]                      M_AXI_AWCACHE;
wire [2:0]                      M_AXI_AWPROT;
wire [3:0]                      M_AXI_AWQOS;
wire                            M_AXI_AWUSER;
wire                            M_AXI_AWVALID;
wire                            M_AXI_AWREADY;

// Wチャネル
wire [C_AXI_DATA_WIDTH-1:0]     M_AXI_WDATA;
wire [C_AXI_DATA_WIDTH/8-1:0]   M_AXI_WSTRB;
wire                            M_AXI_WLAST;
wire                            M_AXI_WUSER;
wire                            M_AXI_WVALID;
wire                            M_AXI_WREADY;

// Bチャネル
wire                            M_AXI_BID;
wire [1:0]                      M_AXI_BRESP;
wire                            M_AXI_BUSER;
wire                            M_AXI_BVALID;
wire                            M_AXI_BREADY;

// ARチャネル
wire                            M_AXI_ARID;
wire [31:0]                     M_AXI_ARADDR;
wire [7:0]                      M_AXI_ARLEN;
wire [2:0]                      M_AXI_ARSIZE;
wire [1:0]                      M_AXI_ARBURST;
wire [1:0]                      M_AXI_ARLOCK;
wire [3:0]                      M_AXI_ARCACHE;
wire [2:0]                      M_AXI_ARPROT;
wire [3:0]                      M_AXI_ARQOS;
wire                            M_AXI_ARUSER;
wire                            M_AXI_ARVALID;
wire                            M_AXI_ARREADY;

// Rチャネル
wire                            M_AXI_RID;
wire [C_AXI_DATA_WIDTH-1:0]     M_AXI_RDATA;
wire [1:0]                      M_AXI_RRESP;
wire                            M_AXI_RLAST;
wire                            M_AXI_RUSER;
wire                            M_AXI_RVALID;
wire                            M_AXI_RREADY;

/* ----- sasanqua.v 接続 ----- */
sasanqua sasanqua (
    // 制御
    .CLK            (CLK),
    .RST            (RST),
    .STAT           (STAT),

    // AXIバス
    .M_AXI_CLK      (CLK),
    .M_AXI_RSTN     (RSTN),
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


/* ----- BFM接続 ----- */
axi_slave_bfm # (
    .READ_RANDOM_WAIT       (1),
    .C_S_AXI_DATA_WIDTH     (C_AXI_DATA_WIDTH),
    .READ_DATA_IS_INCREMENT (0),
    .C_OFFSET_WIDTH         (C_OFFSET_WIDTH),
    .ARREADY_IS_USUALLY_HIGH(0)
) axi_slave_bfm (
    // クロック
    .ACLK           (CLK),
    .ARESETN        (RSTN),

    // AWチャネル
    .S_AXI_AWID     (M_AXI_AWID),
    .S_AXI_AWADDR   (M_AXI_AWADDR),
    .S_AXI_AWLEN    (M_AXI_AWLEN),
    .S_AXI_AWSIZE   (M_AXI_AWSIZE),
    .S_AXI_AWBURST  (M_AXI_AWBURST),
    .S_AXI_AWLOCK   (M_AXI_AWLOCK),
    .S_AXI_AWCACHE  (M_AXI_AWCACHE),
    .S_AXI_AWPROT   (M_AXI_AWPROT),
    .S_AXI_AWQOS    (M_AXI_AWQOS),
    .S_AXI_AWUSER   (M_AXI_AWUSER),
    .S_AXI_AWVALID  (M_AXI_AWVALID),
    .S_AXI_AWREADY  (M_AXI_AWREADY),

    // Wチャネル
    .S_AXI_WDATA    (M_AXI_WDATA),
    .S_AXI_WSTRB    (M_AXI_WSTRB),
    .S_AXI_WLAST    (M_AXI_WLAST),
    .S_AXI_WUSER    (M_AXI_WUSER),
    .S_AXI_WVALID   (M_AXI_WVALID),
    .S_AXI_WREADY   (M_AXI_WREADY),

    // Bチャネル
    .S_AXI_BID      (M_AXI_BID),
    .S_AXI_BRESP    (M_AXI_BRESP),
    .S_AXI_BUSER    (M_AXI_BUSER),
    .S_AXI_BVALID   (M_AXI_BVALID),
    .S_AXI_BREADY   (M_AXI_BREADY),

    // ARチャネル
    .S_AXI_ARID     (M_AXI_ARID),
    .S_AXI_ARADDR   (M_AXI_ARADDR),
    .S_AXI_ARLEN    (M_AXI_ARLEN),
    .S_AXI_ARSIZE   (M_AXI_ARSIZE),
    .S_AXI_ARBURST  (M_AXI_ARBURST),
    .S_AXI_ARLOCK   (M_AXI_ARLOCK),
    .S_AXI_ARCACHE  (M_AXI_ARCACHE),
    .S_AXI_ARPROT   (M_AXI_ARPROT),
    .S_AXI_ARQOS    (M_AXI_ARQOS),
    .S_AXI_ARUSER   (M_AXI_ARUSER),
    .S_AXI_ARVALID  (M_AXI_ARVALID),
    .S_AXI_ARREADY  (M_AXI_ARREADY),

    // Rチャネル
    .S_AXI_RID      (M_AXI_RID),
    .S_AXI_RDATA    (M_AXI_RDATA),
    .S_AXI_RRESP    (M_AXI_RRESP),
    .S_AXI_RLAST    (M_AXI_RLAST),
    .S_AXI_RUSER    (M_AXI_RUSER),
    .S_AXI_RVALID   (M_AXI_RVALID),
    .S_AXI_RREADY   (M_AXI_RREADY)
);

task write_inst;
reg [8:0] c;
integer fd, i, num;
begin
    i = 0;
    fd = $fopen("../../../../../../design/tb/test.bin", "rb");
    while ($feof(fd) == 0) begin
        c = $fgetc(fd); axi_slave_bfm.ram_array[i][7:0]    = c[7:0];
        c = $fgetc(fd); axi_slave_bfm.ram_array[i][15:8]   = c[7:0];
        c = $fgetc(fd); axi_slave_bfm.ram_array[i][23:16]  = c[7:0];
        c = $fgetc(fd); axi_slave_bfm.ram_array[i][31:24]  = c[7:0];
        i = i + 1;
    end
end
endtask

task write_rv32i_test_inst;
integer i;
begin
    for (i = 0; i < 4096; i = i + 1) begin
        axi_slave_bfm.ram_array[i] = 32'b0;
    end

    axi_slave_bfm.ram_array[ 0] = 32'h00a00093;  // addi x1, x0, 10
    axi_slave_bfm.ram_array[ 1] = 32'h00100133;  // add x2, x0, x1
    axi_slave_bfm.ram_array[ 2] = 32'h00000013;  // nop
    axi_slave_bfm.ram_array[ 3] = 32'h001001b3;  // add x3, x0, x1
    axi_slave_bfm.ram_array[ 4] = 32'h00000013;  // nop
    axi_slave_bfm.ram_array[ 5] = 32'h00000013;  // nop
    axi_slave_bfm.ram_array[ 6] = 32'h00100233;  // add x4, x0, x1
    axi_slave_bfm.ram_array[ 7] = 32'h00000013;  // nop
    axi_slave_bfm.ram_array[ 8] = 32'h00000013;  // nop
    axi_slave_bfm.ram_array[ 9] = 32'h00000013;  // nop
    axi_slave_bfm.ram_array[10] = 32'h001002b3;  // add x5, x0, x1

    axi_slave_bfm.ram_array[15] = 32'h00000083;  // lb x1, 0(x0)
    axi_slave_bfm.ram_array[16] = 32'h00004083;  // lbu x1, 0(x0)
    axi_slave_bfm.ram_array[17] = 32'h00001083;  // lh x1, 0(x0)
    axi_slave_bfm.ram_array[18] = 32'h00005083;  // lhu x1, 0(x0)
    axi_slave_bfm.ram_array[19] = 32'h00002083;  // lw x1, 0(x0)

    axi_slave_bfm.ram_array[20] = 32'h00000083;  // lb x1, 0(x0)
    axi_slave_bfm.ram_array[21] = 32'h00100083;  // lb x1, 1(x0)
    axi_slave_bfm.ram_array[22] = 32'h00200083;  // lb x1, 2(x0)
    axi_slave_bfm.ram_array[23] = 32'h00300083;  // lb x1, 3(x0)

    axi_slave_bfm.ram_array[31] = 32'h00001083;  // lh x1, 0(x0)
    axi_slave_bfm.ram_array[32] = 32'h00101083;  // lh x1, 1(x0)
    axi_slave_bfm.ram_array[33] = 32'h00201083;  // lh x1, 2(x0)

    axi_slave_bfm.ram_array[40] = 32'h00100023;  // sb x1, 0(x0)
    axi_slave_bfm.ram_array[41] = 32'h00101023;  // sh x1, 0(x0)
    axi_slave_bfm.ram_array[42] = 32'h00102023;  // sw x1, 0(x0)

    axi_slave_bfm.ram_array[50] = 32'h00100023;  // sb x1, 0(x0)
    axi_slave_bfm.ram_array[51] = 32'h001000a3;  // sb x1, 1(x0)
    axi_slave_bfm.ram_array[52] = 32'h00100123;  // sb x1, 2(x0)
    axi_slave_bfm.ram_array[53] = 32'h001001a3;  // sb x1, 3(x0)

    axi_slave_bfm.ram_array[60] = 32'h00101023;  // sh x1, 0(x0)
    axi_slave_bfm.ram_array[61] = 32'h001010a3;  // sh x1, 1(x0)
    axi_slave_bfm.ram_array[62] = 32'h00101123;  // sh x1, 2(x0)

    axi_slave_bfm.ram_array[70] = 32'h00a00093;  // addi x1, x0, 10
    axi_slave_bfm.ram_array[71] = 32'h00a00113;  // addi x2, x0, 10
    axi_slave_bfm.ram_array[72] = 32'h00208463;  // beq x1, x2, 8
    axi_slave_bfm.ram_array[73] = 32'h00e00193;  // addi x3, x0, 14
    axi_slave_bfm.ram_array[74] = 32'h00f00193;  // addi x3, x0, 15
end
endtask

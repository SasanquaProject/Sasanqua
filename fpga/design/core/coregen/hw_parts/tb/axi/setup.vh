/* ----- Sasanqua ----- */
wire [31:0] GP;
wire [3:0]  STAT;

/* ----- AXI-BFM 接続 ----- */
// リセット
assign RSTN = ~RST;

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

axi_slave_bfm # (
    .C_S_AXI_DATA_WIDTH     (C_AXI_DATA_WIDTH),
    .C_OFFSET_WIDTH         (C_OFFSET_WIDTH),
    .WRITE_RANDOM_WAIT      (1),
    .READ_RANDOM_WAIT       (1),
    .READ_DATA_IS_INCREMENT (0),
    .ARREADY_IS_USUALLY_HIGH(0),
    .AWREADY_IS_USUALLY_HIGH(0)
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

/* ----- コプロセッサパッケージ接続用 ----- */
// 制御
wire            COP_FLUSH;
wire            COP_STALL;
wire            COP_MEM_WAIT;

// Check 接続
wire [31:0]     COP_C_O_PC;
wire [16:0]     COP_C_O_OPCODE;
wire [4:0]      COP_C_O_RD;
wire [4:0]      COP_C_O_RS1;
wire [4:0]      COP_C_O_RS2;
wire [31:0]     COP_C_O_IMM;
wire            COP_C_I_ACCEPT;
wire  [31:0]    COP_C_I_PC;
wire  [4:0]     COP_C_I_RD;
wire  [4:0]     COP_C_I_RS1;
wire  [4:0]     COP_C_I_RS2;

// Exec 接続
wire            COP_E_O_ALLOW;
wire [31:0]     COP_E_O_RS1_DATA;
wire [31:0]     COP_E_O_RS2_DATA;
wire            COP_E_I_ALLOW;
wire            COP_E_I_VALID;
wire  [31:0]    COP_E_I_PC;
wire            COP_E_I_REG_W_EN;
wire  [4:0]     COP_E_I_REG_W_RD;
wire  [31:0]    COP_E_I_REG_W_DATA;
wire            COP_E_I_EXC_EN;
wire  [3:0]     COP_E_I_EXC_CODE;

sasanqua_cop sasanqua_cop (
    // 制御
    .CLK                (CLK),
    .RST                (RST),
    .FLUSH              (COP_FLUSH),
    .STALL              (COP_STALL),
    .MEM_WAIT           (COP_MEM_WAIT),

    // Check 接続
    .C_I_PC             (COP_C_O_PC),
    .C_I_OPCODE         (COP_C_O_OPCODE),
    .C_I_RD             (COP_C_O_RD),
    .C_I_RS1            (COP_C_O_RS1),
    .C_I_RS2            (COP_C_O_RS2),
    .C_I_IMM            (COP_C_O_IMM),
    .C_O_ACCEPT         (COP_C_I_ACCEPT),
    .C_O_PC             (COP_C_I_PC),
    .C_O_RD             (COP_C_I_RD),
    .C_O_RS1            (COP_C_I_RS1),
    .C_O_RS2            (COP_C_I_RS2),

    // Exec 接続
    .E_I_ALLOW          (COP_E_O_ALLOW),
    .E_I_RS1_DATA       (COP_E_O_RS1_DATA),
    .E_I_RS2_DATA       (COP_E_O_RS2_DATA),
    .E_O_ALLOW          (COP_E_I_ALLOW),
    .E_O_VALID          (COP_E_I_VALID),
    .E_O_PC             (COP_E_I_PC),
    .E_O_REG_W_EN       (COP_E_I_REG_W_EN),
    .E_O_REG_W_RD       (COP_E_I_REG_W_RD),
    .E_O_REG_W_DATA     (COP_E_I_REG_W_DATA),
    .E_O_EXC_EN         (COP_E_I_EXC_EN),
    .E_O_EXC_CODE       (COP_E_I_EXC_CODE)
);

/* ----- sasanqua.v 接続 ----- */
sasanqua # (
    .START_ADDR         (0)
) sasanqua (
    // 制御
    .CLK                (CLK),
    .RST                (RST),
    .GP                 (GP),
    .STAT               (STAT),

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

    // コプロセッサパッケージ接続
    .COP_FLUSH          (COP_FLUSH),
    .COP_STALL          (COP_STALL),
    .COP_MEM_WAIT       (COP_MEM_WAIT),
    .COP_C_O_PC         (COP_C_O_PC),
    .COP_C_O_OPCODE     (COP_C_O_OPCODE),
    .COP_C_O_RD         (COP_C_O_RD),
    .COP_C_O_RS1        (COP_C_O_RS1),
    .COP_C_O_RS2        (COP_C_O_RS2),
    .COP_C_O_IMM        (COP_C_O_IMM),
    .COP_C_I_ACCEPT     (COP_C_I_ACCEPT),
    .COP_C_I_PC         (COP_C_I_PC),
    .COP_C_I_RD         (COP_C_I_RD),
    .COP_C_I_RS1        (COP_C_I_RS1),
    .COP_C_I_RS2        (COP_C_I_RS2),
    .COP_E_O_ALLOW      (COP_E_O_ALLOW),
    .COP_E_O_RS1_DATA   (COP_E_O_RS1_DATA),
    .COP_E_O_RS2_DATA   (COP_E_O_RS2_DATA),
    .COP_E_I_ALLOW      (COP_E_I_ALLOW),
    .COP_E_I_VALID      (COP_E_I_VALID),
    .COP_E_I_PC         (COP_E_I_PC),
    .COP_E_I_REG_W_EN   (COP_E_I_REG_W_EN),
    .COP_E_I_REG_W_RD   (COP_E_I_REG_W_RD),
    .COP_E_I_REG_W_DATA (COP_E_I_REG_W_DATA),
    .COP_E_I_EXC_EN     (COP_E_I_EXC_EN),
    .COP_E_I_EXC_CODE   (COP_E_I_EXC_CODE)
);

task write_inst;
input integer fd;
reg [8:0] c;
integer i, num;
begin
    i = 0;
    while ($feof(fd) == 0) begin
        c = $fgetc(fd); axi_slave_bfm.ram_array[i][7:0]    = c[7:0];
        c = $fgetc(fd); axi_slave_bfm.ram_array[i][15:8]   = c[7:0];
        c = $fgetc(fd); axi_slave_bfm.ram_array[i][23:16]  = c[7:0];
        c = $fgetc(fd); axi_slave_bfm.ram_array[i][31:24]  = c[7:0];
        i = i + 1;
    end
end
endtask

task write_handwrite_inst;
integer i;
begin
    for (i = 0; i < 4096; i = i + 1) begin
        axi_slave_bfm.ram_array[i] = 32'b0;
    end

    // データ用
    axi_slave_bfm.ram_array[512] = 32'h78563412;

    // 命令用
    axi_slave_bfm.ram_array[  0] = 32'h00a00093;  // addi x1, x0, 10
    axi_slave_bfm.ram_array[  1] = 32'h00100133;  // add x2, x0, x1
    axi_slave_bfm.ram_array[  2] = 32'h00000013;  // nop
    axi_slave_bfm.ram_array[  3] = 32'h001001b3;  // add x3, x0, x1
    axi_slave_bfm.ram_array[  4] = 32'h00000013;  // nop
    axi_slave_bfm.ram_array[  5] = 32'h00000013;  // nop
    axi_slave_bfm.ram_array[  6] = 32'h00100233;  // add x4, x0, x1
    axi_slave_bfm.ram_array[  7] = 32'h00000013;  // nop
    axi_slave_bfm.ram_array[  8] = 32'h00000013;  // nop
    axi_slave_bfm.ram_array[  9] = 32'h00000013;  // nop
    axi_slave_bfm.ram_array[ 10] = 32'h001002b3;  // add x5, x0, x1

    axi_slave_bfm.ram_array[ 20] = 32'h00100093;  // addi x1, 1
    axi_slave_bfm.ram_array[ 21] = 32'h00b09093;  // slli x1, 11  : x1 = 2048
    axi_slave_bfm.ram_array[ 22] = 32'h00008103;  // lb x2, 0(x1)
    axi_slave_bfm.ram_array[ 23] = 32'h0000c103;  // lbu x2, 0(x1)
    axi_slave_bfm.ram_array[ 24] = 32'h00009103;  // lh x2, 0(x1)
    axi_slave_bfm.ram_array[ 25] = 32'h0000d103;  // lhu x2, 0(x1)
    axi_slave_bfm.ram_array[ 26] = 32'h0000a103;  // lw x2, 0(x1)

    axi_slave_bfm.ram_array[ 30] = 32'h0000c103;  // lbu x2, 0(x1)
    axi_slave_bfm.ram_array[ 31] = 32'h0010c103;  // lbu x2, 1(x1)
    axi_slave_bfm.ram_array[ 32] = 32'h0020c103;  // lbu x2, 2(x1)
    axi_slave_bfm.ram_array[ 33] = 32'h0030c103;  // lbu x2, 3(x1)

    axi_slave_bfm.ram_array[ 40] = 32'h00009103;  // lh x2, 0(x1)
    axi_slave_bfm.ram_array[ 41] = 32'h00109103;  // lh x2, 1(x1)
    axi_slave_bfm.ram_array[ 42] = 32'h00209103;  // lh x2, 2(x1)

    axi_slave_bfm.ram_array[ 50] = 32'h01200113;  // addi x2, x0, 0x12
    axi_slave_bfm.ram_array[ 51] = 32'h00208023;  // sb x2, 0(x1)
    axi_slave_bfm.ram_array[ 52] = 32'h002080a3;  // sb x2, 1(x1)
    axi_slave_bfm.ram_array[ 53] = 32'h00208123;  // sb x2, 2(x1)
    axi_slave_bfm.ram_array[ 54] = 32'h002081a3;  // sb x2, 3(x1)
    axi_slave_bfm.ram_array[ 55] = 32'h0000a183;  // lw x3, 0(x1)

    axi_slave_bfm.ram_array[ 60] = 32'h12300113;  // addi x2, x0, 0x123
    axi_slave_bfm.ram_array[ 61] = 32'h00209023;  // sh x2, 0(x1)
    axi_slave_bfm.ram_array[ 62] = 32'h0000a183;  // lw x3, 0(x1)
    axi_slave_bfm.ram_array[ 63] = 32'h002090a3;  // sh x2, 1(x1)
    axi_slave_bfm.ram_array[ 64] = 32'h0000a183;  // lw x3, 0(x1)
    axi_slave_bfm.ram_array[ 65] = 32'h00209123;  // sh x2, 2(x1)
    axi_slave_bfm.ram_array[ 66] = 32'h0000a183;  // lw x3, 0(x1)

    axi_slave_bfm.ram_array[ 70] = 32'h12121137;  // lui x2, 0x12121
    axi_slave_bfm.ram_array[ 71] = 32'h21210113;  // addi x2, x2, 0x212
    axi_slave_bfm.ram_array[ 72] = 32'h0020a023;  // sw x2, 0(x1)
    axi_slave_bfm.ram_array[ 73] = 32'h0000a183;  // lw x3, 0(x1)

    axi_slave_bfm.ram_array[ 80] = 32'h00a00093;  // addi x1, x0, 10
    axi_slave_bfm.ram_array[ 81] = 32'h00a00113;  // addi x2, x0, 10
    axi_slave_bfm.ram_array[ 82] = 32'h00208463;  // beq x1, x2, 8
    axi_slave_bfm.ram_array[ 83] = 32'h00e00193;  // addi x3, x0, 14
    axi_slave_bfm.ram_array[ 84] = 32'h00f00193;  // addi x3, x0, 15

    axi_slave_bfm.ram_array[ 90] = 32'h12300093;  // addi x1, x0, 0x123
    axi_slave_bfm.ram_array[ 91] = 32'h30009173;  // csrrw x2, 0x300, x1
    axi_slave_bfm.ram_array[ 92] = 32'h30095173;  // csrrwi x2, 0x300, 0x12
    axi_slave_bfm.ram_array[ 93] = 32'hff000093;  // addi x1, x0, 0xff0
    axi_slave_bfm.ram_array[ 94] = 32'h3000b173;  // csrrc x2, 0x300, x1
    axi_slave_bfm.ram_array[ 95] = 32'h3007f173;  // csrrci x2, 0x300, 0xf
    axi_slave_bfm.ram_array[ 96] = 32'h3000a173;  // csrrs x2, 0x300, x1
    axi_slave_bfm.ram_array[ 97] = 32'h300ee173;  // csrrsi x2, 0x300, 0x1d

    axi_slave_bfm.ram_array[100] = 32'h00000093;  // addi x1, x0, 0
    axi_slave_bfm.ram_array[101] = 32'h000010b7;  // lui x1, 0x1  : x1 = 4096 (at 1024)
    axi_slave_bfm.ram_array[102] = 32'h12300113;  // addi x2, x0, 0x123
    axi_slave_bfm.ram_array[103] = 32'h0020a023;  // sw x2, 0(x1)
    axi_slave_bfm.ram_array[104] = 32'h00100093;  // addi x1, 1
    axi_slave_bfm.ram_array[105] = 32'h00b09093;  // slli x1, 11  : x1 = 2048 (at 512)
    axi_slave_bfm.ram_array[106] = 32'h0000a103;  // lw x2, 0(x1)
    axi_slave_bfm.ram_array[107] = 32'h00000093;  // addi x1, x0, 0
    axi_slave_bfm.ram_array[108] = 32'h000010b7;  // lui x1, 0x1  : x1 = 4096 (at 1024)
    axi_slave_bfm.ram_array[109] = 32'h0000a103;  // lw x2, 0(x1)
end
endtask

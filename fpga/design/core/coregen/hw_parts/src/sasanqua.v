module sasanqua
    # (
        parameter START_ADDR = 32'h0,
        parameter COP_NUMS   = 32'd1,
        parameter PNUMS      = COP_NUMS+1
    )
    (
        /* ----- 制御 ------ */
        input wire                      CLK,
        input wire                      RST,

        /* ----- 状態 ----- */
        output wire [31:0]              GP,
        output wire [3:0]               STAT,

        /* ----- AXIバス ----- */
        // AWチャネル
        output wire                     M_AXI_AWID,
        output wire [31:0]              M_AXI_AWADDR,
        output wire [7:0]               M_AXI_AWLEN,
        output wire [2:0]               M_AXI_AWSIZE,
        output wire [1:0]               M_AXI_AWBURST,
        output wire [1:0]               M_AXI_AWLOCK,
        output wire [3:0]               M_AXI_AWCACHE,
        output wire [2:0]               M_AXI_AWPROT,
        output wire [3:0]               M_AXI_AWQOS,
        output wire                     M_AXI_AWUSER,
        output wire                     M_AXI_AWVALID,
        input  wire                     M_AXI_AWREADY,

        // Wチャネル
        output wire [31:0]              M_AXI_WDATA,
        output wire [3:0]               M_AXI_WSTRB,
        output wire                     M_AXI_WLAST,
        output wire                     M_AXI_WUSER,
        output wire                     M_AXI_WVALID,
        input  wire                     M_AXI_WREADY,

        // Bチャネル
        input  wire                     M_AXI_BID,
        input  wire [1:0]               M_AXI_BRESP,
        input  wire                     M_AXI_BUSER,
        input  wire                     M_AXI_BVALID,
        output wire                     M_AXI_BREADY,

        // ARチャネル
        output wire                     M_AXI_ARID,
        output wire [31:0]              M_AXI_ARADDR,
        output wire [7:0]               M_AXI_ARLEN,
        output wire [2:0]               M_AXI_ARSIZE,
        output wire [1:0]               M_AXI_ARBURST,
        output wire [1:0]               M_AXI_ARLOCK,
        output wire [3:0]               M_AXI_ARCACHE,
        output wire [2:0]               M_AXI_ARPROT,
        output wire [3:0]               M_AXI_ARQOS,
        output wire                     M_AXI_ARUSER,
        output wire                     M_AXI_ARVALID,
        input  wire                     M_AXI_ARREADY,

        // Rチャネル
        input  wire                     M_AXI_RID,
        input  wire [31:0]              M_AXI_RDATA,
        input  wire [1:0]               M_AXI_RRESP,
        input  wire                     M_AXI_RLAST,
        input  wire                     M_AXI_RUSER,
        input  wire                     M_AXI_RVALID,
        output wire                     M_AXI_RREADY,

        /* ----- コプロセッサパッケージ接続 ----- */
        // 制御
        output wire                     COP_FLUSH,
        output wire                     COP_STALL,
        output wire                     COP_MEM_WAIT,

        // Check 接続
        output wire [(32*PNUMS-1):0]    COP_C_O_PC,
        output wire [(16*PNUMS-1):0]    COP_C_O_OPCODE,
        output wire [(32*PNUMS-1):0]    COP_C_O_IMM,
        input wire  [( 1*PNUMS-1):0]    COP_C_I_ACCEPT,

        // Exec 接続
        output wire [( 1*COP_NUMS-1):0] COP_E_O_ALLOW,
        output wire [( 5*COP_NUMS-1):0] COP_E_O_RD,
        output wire [(32*COP_NUMS-1):0] COP_E_O_RS1_DATA,
        output wire [(32*COP_NUMS-1):0] COP_E_O_RS2_DATA,
        input wire  [( 1*COP_NUMS-1):0] COP_E_I_ALLOW,
        input wire  [( 1*COP_NUMS-1):0] COP_E_I_VALID,
        input wire  [(32*COP_NUMS-1):0] COP_E_I_PC,
        input wire  [( 1*COP_NUMS-1):0] COP_E_I_REG_W_EN,
        input wire  [( 5*COP_NUMS-1):0] COP_E_I_REG_W_RD,
        input wire  [(32*COP_NUMS-1):0] COP_E_I_REG_W_DATA,
        input wire  [( 1*COP_NUMS-1):0] COP_E_I_EXC_EN,
        input wire  [( 4*COP_NUMS-1):0] COP_E_I_EXC_CODE
    );

    /* ----- 状態 ----- */
    assign GP   = core.main.reg_std_rv32i_0.registers[3];
    assign STAT = {
        core.main.flush,
        core.main.stall,
        core.main.INT_EN,
        core.main.MEM_WAIT
    };

    /* ----- Memory ----- */
    wire        mem_wait;
    wire        inst_rden, inst_rvalid, data_rden, data_rvalid, data_wren;
    wire [3:0]  data_wstrb;
    wire [31:0] inst_riaddr, inst_roaddr, inst_rdata, data_riaddr, data_roaddr, data_rdata, data_waddr, data_wdata;

    mem_axi mem (
        // 制御
        .CLK            (CLK),
        .RST            (RST),
        .MEM_WAIT       (mem_wait),

        // メモリアクセス
        .INST_RDEN      (inst_rden),
        .INST_RIADDR    (inst_riaddr),
        .INST_ROADDR    (inst_roaddr),
        .INST_RVALID    (inst_rvalid),
        .INST_RDATA     (inst_rdata),
        .DATA_RDEN      (data_rden),
        .DATA_RIADDR    (data_riaddr),
        .DATA_ROADDR    (data_roaddr),
        .DATA_RVALID    (data_rvalid),
        .DATA_RDATA     (data_rdata),
        .DATA_WREN      (data_wren),
        .DATA_WSTRB     (data_wstrb),
        .DATA_WADDR     (data_waddr),
        .DATA_WDATA     (data_wdata),

        // AXIバス
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

    /* ----- PLIC ----- */
    plic plic ();

    /* ----- CLINT ----- */
    wire        int_en;
    wire [3:0]  int_code;

    wire        clint_rvalid;
    wire [31:0] clint_roaddr, clint_rdata;

    clint # (
        .BASE_ADDR  (32'h0200_0000),
        .TICK_CNT   (32'd100) // 1/100
    ) clint (
        // 制御
        .CLK        (CLK),
        .RST        (RST),

        // レジスタアクセス
        .RDEN       (data_rden),
        .RIADDR     (data_riaddr),
        .ROADDR     (clint_roaddr),
        .RVALID     (clint_rvalid),
        .RDATA      (clint_rdata),
        .WREN       (data_wren),
        .WADDR      (data_waddr),
        .WDATA      (data_wdata),

        // 割り込み
        .INT_EN     (int_en),
        .INT_CODE   (int_code)
    );

    /* ----- Core ----- */
    wire [31:0] core_data_roaddr = data_rvalid ? data_roaddr : clint_roaddr;
    wire        core_data_rvalid = data_rvalid ? data_rvalid : clint_rvalid;
    wire [31:0] core_data_rdata  = data_rvalid ? data_rdata  : clint_rdata;

    assign COP_MEM_WAIT = mem_wait;

    core # (
        .HART_ID            (0),
        .START_ADDR         (START_ADDR),
        .COP_NUMS           (COP_NUMS)
    ) core (
        // 制御
        .CLK                (CLK),
        .RST                (RST),

        // MMU接続
        .INST_RDEN          (inst_rden),
        .INST_RIADDR        (inst_riaddr),
        .INST_ROADDR        (inst_roaddr),
        .INST_RVALID        (inst_rvalid),
        .INST_RDATA         (inst_rdata),
        .DATA_RDEN          (data_rden),
        .DATA_RIADDR        (data_riaddr),
        .DATA_ROADDR        (core_data_roaddr),
        .DATA_RVALID        (core_data_rvalid),
        .DATA_RDATA         (core_data_rdata),
        .DATA_WREN          (data_wren),
        .DATA_WSTRB         (data_wstrb),
        .DATA_WADDR         (data_waddr),
        .DATA_WDATA         (data_wdata),
        .MEM_WAIT           (mem_wait),

        // 割り込み
        .INT_EN             (int_en),
        .INT_CODE           (int_code),

        // コプロセッサパッケージ接続
        .COP_FLUSH          (COP_FLUSH),
        .COP_STALL          (COP_STALL),
        .COP_C_O_PC         (COP_C_O_PC),
        .COP_C_O_OPCODE     (COP_C_O_OPCODE),
        .COP_C_O_IMM        (COP_C_O_IMM),
        .COP_C_I_ACCEPT     (COP_C_I_ACCEPT),
        .COP_E_O_ALLOW      (COP_E_O_ALLOW),
        .COP_E_O_RD         (COP_E_O_RD),
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

endmodule

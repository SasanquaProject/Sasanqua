module core
    # (
        parameter HART_ID    = 32'h0,
        parameter START_ADDR = 32'h2000_0000
    )
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,

        /* ----- Mem接続 ----- */
        // 命令
        output wire         INST_RDEN,
        output wire [31:0]  INST_RIADDR,
        input wire  [31:0]  INST_ROADDR,
        input wire          INST_RVALID,
        input wire  [31:0]  INST_RDATA,

        // データ
        output wire         DATA_RDEN,
        output wire [31:0]  DATA_RIADDR,
        input wire  [31:0]  DATA_ROADDR,
        input wire          DATA_RVALID,
        input wire  [31:0]  DATA_RDATA,
        output wire         DATA_WREN,
        output wire [31:0]  DATA_WADDR,
        output wire [31:0]  DATA_WDATA,

        // ハザード
        input wire          MEM_WAIT
    );

    /* ----- MMU ----- */
    mmu mmu ();

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
        .RDEN       (DATA_RDEN),
        .RIADDR     (DATA_RIADDR),
        .ROADDR     (clint_roaddr),
        .RVALID     (clint_rvalid),
        .RDATA      (clint_rdata),
        .WREN       (DATA_WREN),
        .WADDR      (DATA_WADDR),
        .WDATA      (DATA_WDATA),

        // 割り込み
        .INT_EN     (int_en),
        .INT_CODE   (int_code)
    );

    /* ----- Main ----- */
    wire [31:0] data_roaddr = DATA_RVALID ? DATA_ROADDR : clint_roaddr;
    wire        data_rvalid = DATA_RVALID ? DATA_RVALID : clint_rvalid;
    wire [31:0] data_rdata  = DATA_RVALID ? DATA_RDATA  : clint_rdata;

    main # (
        .START_ADDR     (START_ADDR)
    ) main (
        // 制御
        .CLK            (CLK),
        .RST            (RST),

        // MMU接続
        .INST_RDEN      (INST_RDEN),
        .INST_RIADDR    (INST_RIADDR),
        .INST_ROADDR    (INST_ROADDR),
        .INST_RVALID    (INST_RVALID),
        .INST_RDATA     (INST_RDATA),
        .DATA_RDEN      (DATA_RDEN),
        .DATA_RIADDR    (DATA_RIADDR),
        .DATA_ROADDR    (data_roaddr),
        .DATA_RVALID    (data_rvalid),
        .DATA_RDATA     (data_rdata),
        .DATA_WREN      (DATA_WREN),
        .DATA_WADDR     (DATA_WADDR),
        .DATA_WDATA     (DATA_WDATA),
        .MEM_WAIT       (MEM_WAIT),

        // 割り込み
        .INT_EN         (int_en),
        .INT_CODE       (int_code)
    );

endmodule

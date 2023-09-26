module core
    # (
        parameter HART_ID    = 32'h0,
        parameter START_ADDR = 32'h0
    )
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,

        /* ----- 割り込み ----- */
        input wire          INT_EN,
        input wire  [3:0]   INT_CODE,

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
        output wire [3:0]   DATA_WSTRB,
        output wire [31:0]  DATA_WADDR,
        output wire [31:0]  DATA_WDATA,

        // ハザード
        input wire          MEM_WAIT
    );

    /* ----- MMU ----- */
    wire mmu_wait;

    mmu mmu (
        // 制御
        .CLK                (CLK),
        .RST                (RST),

        // MMU->Mem 接続 (物理アドレス)
        .MEM_INST_RDEN      (INST_RDEN),
        .MEM_INST_RIADDR    (INST_RIADDR),
        .MEM_INST_ROADDR    (INST_ROADDR),
        .MEM_INST_RVALID    (INST_RVALID),
        .MEM_INST_RDATA     (INST_RDATA),
        .MEM_DATA_RDEN      (DATA_RDEN),
        .MEM_DATA_RIADDR    (DATA_RIADDR),
        .MEM_DATA_ROADDR    (data_roaddr),
        .MEM_DATA_RVALID    (data_rvalid),
        .MEM_DATA_RDATA     (data_rdata),
        .MEM_DATA_WREN      (DATA_WREN),
        .MEM_DATA_WSTRB     (DATA_WSTRB),
        .MEM_DATA_WADDR     (DATA_WADDR),
        .MEM_DATA_WDATA     (DATA_WDATA),
        .MEM_WAIT           (MEM_WAIT),

        // Main->MMU 接続 (物理アドレス or 仮想アドレス)
        .MAIN_INST_RDEN     (main_inst_rden),
        .MAIN_INST_RIADDR   (main_inst_riaddr),
        .MAIN_INST_ROADDR   (main_inst_roaddr),
        .MAIN_INST_RVALID   (main_inst_rvalid),
        .MAIN_INST_RDATA    (main_inst_rdata),
        .MAIN_DATA_RDEN     (main_data_rden),
        .MAIN_DATA_RIADDR   (main_data_riaddr),
        .MAIN_DATA_ROADDR   (main_data_roaddr),
        .MAIN_DATA_RVALID   (main_data_rvalid),
        .MAIN_DATA_RDATA    (main_data_rdata),
        .MAIN_DATA_WREN     (main_data_wren),
        .MAIN_DATA_WSTRB    (main_data_wstrb),
        .MAIN_DATA_WADDR    (main_data_waddr),
        .MAIN_DATA_WDATA    (main_data_wdata),
        .MMU_WAIT           (mmu_wait)
    );

    /* ----- Main ----- */
    wire        main_inst_rden, main_inst_rvalid;
    wire [31:0] main_inst_riaddr, main_inst_roaddr, main_inst_rdata;
    wire        main_data_rden, main_data_rvalid, main_data_wren;
    wire [3:0]  main_data_wstrb;
    wire [31:0] main_data_riaddr, main_data_roaddr, main_data_rdata, main_data_waddr, main_data_wdata;

    main # (
        .START_ADDR     (START_ADDR)
    ) main (
        // 制御
        .CLK            (CLK),
        .RST            (RST),

        // MMU接続
        .INST_RDEN      (main_inst_rden),
        .INST_RIADDR    (main_inst_riaddr),
        .INST_ROADDR    (main_inst_roaddr),
        .INST_RVALID    (main_inst_rvalid),
        .INST_RDATA     (main_inst_rdata),
        .DATA_RDEN      (main_data_rden),
        .DATA_RIADDR    (main_data_riaddr),
        .DATA_ROADDR    (main_data_roaddr),
        .DATA_RVALID    (main_data_rvalid),
        .DATA_RDATA     (main_data_rdata),
        .DATA_WREN      (main_data_wren),
        .DATA_WSTRB     (main_data_wstrb),
        .DATA_WADDR     (main_data_waddr),
        .DATA_WDATA     (main_data_wdata),
        .MEM_WAIT       (mmu_wait),

        // 割り込み
        .INT_EN         (int_en),
        .INT_CODE       (int_code)
    );

endmodule

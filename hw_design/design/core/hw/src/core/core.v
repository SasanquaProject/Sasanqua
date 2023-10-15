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
        .MEM_DATA_ROADDR    (DATA_ROADDR),
        .MEM_DATA_RVALID    (DATA_RVALID),
        .MEM_DATA_RDATA     (DATA_RDATA),
        .MEM_DATA_WREN      (DATA_WREN),
        .MEM_DATA_WSTRB     (DATA_WSTRB),
        .MEM_DATA_WADDR     (DATA_WADDR),
        .MEM_DATA_WDATA     (DATA_WDATA),
        .MEM_WAIT           (MEM_WAIT),

        // Main->MMU 接続 (物理アドレス or 仮想アドレス)
        .MAIN_INST_RDEN     (inst_rden),
        .MAIN_INST_RIADDR   (inst_riaddr),
        .MAIN_INST_ROADDR   (inst_roaddr),
        .MAIN_INST_RVALID   (inst_rvalid),
        .MAIN_INST_RDATA    (inst_rdata),
        .MAIN_DATA_RDEN     (data_rden),
        .MAIN_DATA_RIADDR   (data_riaddr),
        .MAIN_DATA_ROADDR   (data_roaddr),
        .MAIN_DATA_RVALID   (data_rvalid),
        .MAIN_DATA_RDATA    (data_rdata),
        .MAIN_DATA_WREN     (data_wren),
        .MAIN_DATA_WSTRB    (data_wstrb),
        .MAIN_DATA_WADDR    (data_waddr),
        .MAIN_DATA_WDATA    (data_wdata),
        .MMU_WAIT           (mmu_wait)
    );

    /* ----- Main ----- */
    wire        inst_rden, inst_rvalid;
    wire [31:0] inst_riaddr, inst_roaddr, inst_rdata;
    wire        data_rden, data_rvalid, data_wren;
    wire [3:0]  data_wstrb;
    wire [31:0] data_riaddr, data_roaddr, data_rdata, data_waddr, data_wdata;

    main # (
        .START_ADDR     (START_ADDR)
    ) main (
        // 制御
        .CLK            (CLK),
        .RST            (RST),

        // MMU接続
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
        .MEM_WAIT       (mmu_wait),

        // 割り込み
        .INT_EN         (INT_EN),
        .INT_CODE       (INT_CODE)
    );

endmodule
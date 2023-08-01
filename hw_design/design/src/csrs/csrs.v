module csrs
    (
        /* ----- 制御 ----- */
        input wire CLK,
        input wire RST,

        /* ----- CSRアクセス ----- */
        // 読み
        input wire          RDEN,
        input wire  [11:0]  RADDR,
        output wire         RVALID,
        output wire [31:0]  RDATA,

        // 書き
        input wire          WREN,
        input wire  [11:0]  WADDR,
        input wire  [31:0]  WDATA
    );

    /* ----- 配線 ----- */
    assign RVALID   = machine_rvalid | hypervisor_rvalid | supervisor_rvalid | user_rvalid;
    assign RDATA    = machine_rdata | hypervisor_rdata | supervisor_rdata | user_rdata;

    /* ---- Machine-Level CSRs ----- */
    wire        machine_rvalid;
    wire [31:0] machine_rdata;

    csrs_machine csrs_machine (
        // 制御
        .CLK    (CLK),
        .RST    (RST),

        // アクセス
        .RDEN   (RDEN),
        .RADDR  (RADDR),
        .RVALID (machine_rvalid),
        .RDATA  (machine_rdata),
        .WREN   (WREN),
        .WADDR  (WADDR),
        .WDATA  (WDATA)
    );

    /* ---- Hypervisor-Level CSRs ----- */
    wire        hypervisor_rvalid;
    wire [31:0] hypervisor__rdata;

    csrs_hypervisor csrs_hypervisor (
        // 制御
        .CLK    (CLK),
        .RST    (RST),

        // アクセス
        .RDEN   (RDEN),
        .RADDR  (RADDR),
        .RVALID (hypervisor_rvalid),
        .RDATA  (hypervisor_rdata),
        .WREN   (WREN),
        .WADDR  (WADDR),
        .WDATA  (WDATA)
    );

    /* ---- Supervisor-Level CSRs ----- */
    wire        supervisor_rvalid;
    wire [31:0] supervisor_rdata;

    csrs_supervisor csrs_supervisor (
        // 制御
        .CLK    (CLK),
        .RST    (RST),

        // アクセス
        .RDEN   (RDEN),
        .RADDR  (RADDR),
        .RVALID (supervisor_rvalid),
        .RDATA  (supervisor_rdata),
        .WREN   (WREN),
        .WADDR  (WADDR),
        .WDATA  (WDATA)
    );

    /* ---- User-Level CSRs ----- */
    wire        user_rvalid;
    wire [31:0] user_rdata;

    csrs_user csrs_user (
        // 制御
        .CLK    (CLK),
        .RST    (RST),

        // アクセス
        .RDEN   (RDEN),
        .RADDR  (RADDR),
        .RVALID (user_rvalid),
        .RDATA  (user_rdata),
        .WREN   (WREN),
        .WADDR  (WADDR),
        .WDATA  (WDATA)
    );

endmodule

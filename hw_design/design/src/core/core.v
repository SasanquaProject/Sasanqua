module core
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,

        /* ----- メモリアクセス信号 ----- */
        // 命令
        output reg          INST_RDEN,
        output reg  [31:0]  INST_RADDR,
        input wire          INST_RVALID,
        input wire  [31:0]  INST_RDATA,

        // データ
        // input wire          DATA_WREN,
        // input wire [31:0]   DATA_WRADDR,
        // input wire [31:0]   DATA_WRDATA,
        output wire         DATA_RDEN,
        output wire [31:0]  DATA_RADDR,
        input wire          DATA_RVALID,
        input wire  [31:0]  DATA_RDATA,

        // ハザード
        input wire          MEM_WAIT
    );

    assign DATA_RDEN    = 1'b0;
    assign DATA_RADDR   = 32'b0;

    /* ----- 命令フェッチ ----- */
    wire        inst_valid;
    wire [31:0] inst_addr, inst_data;

    assign inst_valid   = INST_RVALID;
    assign inst_addr    = INST_RADDR;
    assign inst_data    = INST_RDATA;

    always @ (posedge CLK) begin
        if (RST) begin
            INST_RDEN <= 1'b0;
            INST_RADDR <= 32'hffff_fffc;
        end
        else if (!MEM_WAIT) begin
            INST_RDEN <= 1'b1;
            INST_RADDR <= INST_RADDR + 32'd4;
        end
    end

    /* ----- 命令デコード1 ----- */
    decode_1 decode_1 (
        // 制御
        .CLK    (CLK),
        .RST    (RST)
    );

    /* ----- 命令デコード2 ----- */
    decode_2 decode_2 (
        // 制御
        .CLK    (CLK),
        .RST    (RST)
    );

    /* ----- 実行 ----- */
    exec exec (
        // 制御
        .CLK    (CLK),
        .RST    (RST)
    );

    /* ----- メモリアクセス ----- */


endmodule

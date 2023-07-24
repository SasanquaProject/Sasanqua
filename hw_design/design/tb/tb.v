`timescale 1ns/1ps

module sasanqua_tb;

/* ----- 各種定数 ----- */
localparam integer C_AXI_DATA_WIDTH = 32;
localparam integer C_OFFSET_WIDTH   = 32;
localparam integer STEP             = 1000 / 100;   // 100Mhz

/* ----- クロック ----- */
reg CLK;
reg RST;

always begin
    CLK = 0; #(STEP/2);
    CLK = 1; #(STEP/2);
end

/* ----- sasanqua.v 接続用 ----- */
wire [31:0] STAT;

/* ----- BFM との接続 ----- */
`include "./axi/axi_slave_BFM_setup.vh"

/* ----- 監視対象信号 ----- */


/* ----- テストベンチ本体 ----- */
initial begin
    RST = 0;
    #(STEP*10)

    write_inst;

    RST = 1;
    #(STEP*10);

    RST = 0;
    #(STEP*10);

    #(STEP*4500);

    $stop;
end

endmodule

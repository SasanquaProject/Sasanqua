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
// MMU
wire        MEM_WAIT            = sasanqua.mmu.MEM_WAIT;
wire        INST_RDEN           = sasanqua.mmu.INST_RDEN;
wire [31:0] INST_ADDR           = sasanqua.mmu.INST_RADDR;
wire        INST_VALID          = sasanqua.mmu.INST_RVALID;
wire [31:0] INST_DATA           = sasanqua.mmu.INST_RDATA;
wire        DATA_RDEN           = sasanqua.mmu.DATA_RDEN;
wire [31:0] DATA_ADDR           = sasanqua.mmu.DATA_RADDR;
wire        DATA_VALID          = sasanqua.mmu.DATA_RVALID;
wire [31:0] DATA_DATA           = sasanqua.mmu.DATA_RDATA;

/* ----- テストベンチ本体 ----- */
initial begin
    RST = 0;
    #(STEP*10)

    // write_inst;
    write_dummy_inst;

    RST = 1;
    #(STEP*10);

    RST = 0;
    #(STEP*10);

    #(STEP*4500);

    $stop;
end

endmodule

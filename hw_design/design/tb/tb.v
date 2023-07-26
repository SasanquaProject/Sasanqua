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
wire [31:0] INST_RADDR          = sasanqua.mmu.INST_RADDR;
wire        INST_RVALID         = sasanqua.mmu.INST_RVALID;
wire [31:0] INST_RDATA          = sasanqua.mmu.INST_RDATA;
wire        DATA_RDEN           = sasanqua.mmu.DATA_RDEN;
wire [31:0] DATA_RADDR          = sasanqua.mmu.DATA_RADDR;
wire        DATA_RVALID         = sasanqua.mmu.DATA_RVALID;
wire [31:0] DATA_RDATA          = sasanqua.mmu.DATA_RDATA;

// Core
wire        INST_VALID          = sasanqua.core.inst_valid;
wire [31:0] INST_ADDR           = sasanqua.core.inst_addr;
wire [31:0] INST_DATA           = sasanqua.core.inst_data;

wire        DECODE1_VALID       = sasanqua.core.decode1_valid;
wire [31:0] DECODE1_PC          = sasanqua.core.decode1_pc;
wire [6:0]  DECODE1_OPCODE      = sasanqua.core.decode1_opcode;
wire [4:0]  DECODE1_RD          = sasanqua.core.decode1_rd;
wire [4:0]  DECODE1_RS1         = sasanqua.core.decode1_rs1;
wire [4:0]  DECODE1_RS2         = sasanqua.core.decode1_rs2;
wire [2:0]  DECODE1_FUNCT3      = sasanqua.core.decode1_funct3;
wire [6:0]  DECODE1_FUNCT7      = sasanqua.core.decode1_funct7;
wire [31:0] DECODE1_IMM_I       = sasanqua.core.decode1_imm_i;
wire [31:0] DECODE1_IMM_S       = sasanqua.core.decode1_imm_s;
wire [31:0] DECODE1_IMM_B       = sasanqua.core.decode1_imm_b;
wire [31:0] DECODE1_IMM_U       = sasanqua.core.decode1_imm_u;
wire [31:0] DECODE1_IMM_J       = sasanqua.core.decode1_imm_j;

wire        DECODE2_VALID       = sasanqua.core.decode2_valid;
wire [31:0] DECODE2_PC          = sasanqua.core.decode2_pc;
wire [6:0]  DECODE2_OPCODE      = sasanqua.core.decode2_opcode;
wire [4:0]  DECODE2_RD          = sasanqua.core.decode2_rd;
wire [4:0]  DECODE2_RS1         = sasanqua.core.decode2_rs1;
wire [4:0]  DECODE2_RS2         = sasanqua.core.decode2_rs2;
wire [2:0]  DECODE2_FUNCT3      = sasanqua.core.decode2_funct3;
wire [6:0]  DECODE2_FUNCT7      = sasanqua.core.decode2_funct7;
wire [31:0] DECODE2_IMM         = sasanqua.core.decode2_imm;

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

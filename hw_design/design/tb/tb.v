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
wire        MEM_WAIT                = sasanqua.mmu.MEM_WAIT;
wire        INST_RDEN               = sasanqua.mmu.INST_RDEN;
wire [31:0] INST_RADDR              = sasanqua.mmu.INST_RADDR;
wire        INST_RVALID             = sasanqua.mmu.INST_RVALID;
wire [31:0] INST_RDATA              = sasanqua.mmu.INST_RDATA;
wire        DATA_RDEN               = sasanqua.mmu.DATA_RDEN;
wire [31:0] DATA_RADDR              = sasanqua.mmu.DATA_RADDR;
wire        DATA_RVALID             = sasanqua.mmu.DATA_RVALID;
wire [31:0] DATA_RDATA              = sasanqua.mmu.DATA_RDATA;

// Core: Fetch
wire        INST_VALID              = sasanqua.core.inst_valid;
wire [31:0] INST_ADDR               = sasanqua.core.inst_addr;
wire [31:0] INST_DATA               = sasanqua.core.inst_data;

// Core: Decode 1st
wire        DECODE_1ST_VALID        = sasanqua.core.decode_1st_valid;
wire [31:0] DECODE_1ST_PC           = sasanqua.core.decode_1st_pc;
wire [6:0]  DECODE_1ST_OPCODE       = sasanqua.core.decode_1st_opcode;
wire [4:0]  DECODE_1ST_RD           = sasanqua.core.decode_1st_rd;
wire [4:0]  DECODE_1ST_RS1          = sasanqua.core.decode_1st_rs1;
wire [4:0]  DECODE_1ST_RS2          = sasanqua.core.decode_1st_rs2;
wire [2:0]  DECODE_1ST_FUNCT3       = sasanqua.core.decode_1st_funct3;
wire [6:0]  DECODE_1ST_FUNCT7       = sasanqua.core.decode_1st_funct7;
wire [31:0] DECODE_1ST_IMM_I        = sasanqua.core.decode_1st_imm_i;
wire [31:0] DECODE_1ST_IMM_S        = sasanqua.core.decode_1st_imm_s;
wire [31:0] DECODE_1ST_IMM_B        = sasanqua.core.decode_1st_imm_b;
wire [31:0] DECODE_1ST_IMM_U        = sasanqua.core.decode_1st_imm_u;
wire [31:0] DECODE_1ST_IMM_J        = sasanqua.core.decode_1st_imm_j;

// Core: Decode 2nd
wire        DECODE_2ND_VALID        = sasanqua.core.decode_2nd_valid;
wire [31:0] DECODE_2ND_PC           = sasanqua.core.decode_2nd_pc;
wire [6:0]  DECODE_2ND_OPCODE       = sasanqua.core.decode_2nd_opcode;
wire [4:0]  DECODE_2ND_RD           = sasanqua.core.decode_2nd_rd;
wire [4:0]  DECODE_2ND_RS1          = sasanqua.core.decode_2nd_rs1;
wire [4:0]  DECODE_2ND_RS2          = sasanqua.core.decode_2nd_rs2;
wire [2:0]  DECODE_2ND_FUNCT3       = sasanqua.core.decode_2nd_funct3;
wire [6:0]  DECODE_2ND_FUNCT7       = sasanqua.core.decode_2nd_funct7;
wire [31:0] DECODE_2ND_IMM          = sasanqua.core.decode_2nd_imm;

// Core: Schedule 1st, Register(r)
wire        SCHEDULE_1ST_VALID      = sasanqua.core.schedule_1st_valid;
wire [31:0] SCHEDULE_1ST_PC         = sasanqua.core.schedule_1st_pc;
wire [6:0]  SCHEDULE_1ST_OPCODE     = sasanqua.core.schedule_1st_opcode;
wire [4:0]  SCHEDULE_1ST_RD         = sasanqua.core.schedule_1st_rd;
wire [4:0]  SCHEDULE_1ST_RS1        = sasanqua.core.reg_rs1_v;
wire [4:0]  SCHEDULE_1ST_RS2        = sasanqua.core.reg_rs2_v;
wire [2:0]  SCHEDULE_1ST_FUNCT3     = sasanqua.core.schedule_1st_funct3;
wire [6:0]  SCHEDULE_1ST_FUNCT7     = sasanqua.core.schedule_1st_funct7;
wire [31:0] SCHEDULE_1ST_IMM        = sasanqua.core.schedule_1st_imm;

// Core: Exec
wire        EXEC_REG_W_VALID        = sasanqua.core.reg_w_valid;
wire [4:0]  EXEC_REG_W_RD           = sasanqua.core.reg_w_rd;
wire [31:0] EXEC_REG_W_DATA         = sasanqua.core.reg_w_data;
wire        EXEC_MEM_R_VALID        = sasanqua.core.mem_r_valid;
wire [4:0]  EXEC_MEM_R_RD           = sasanqua.core.mem_r_rd;
wire [31:0] EXEC_MEM_R_ADDR         = sasanqua.core.mem_r_addr;
wire [3:0]  EXEC_MEM_R_STRB         = sasanqua.core.mem_r_strb;
wire        EXEC_MEM_R_SIGNED       = sasanqua.core.mem_r_signed;
wire        EXEC_MEM_W_VALID        = sasanqua.core.mem_w_valid;
wire [31:0] EXEC_MEM_W_ADDR         = sasanqua.core.mem_w_addr;
wire [3:0]  EXEC_MEM_W_STRB         = sasanqua.core.mem_w_strb;
wire [31:0] EXEC_MEM_W_DATA         = sasanqua.core.mem_w_data;

// Core: Cushion
wire        CUSHION_REG_W_VALID     = sasanqua.core.cushion_reg_w_valid;
wire [4:0]  CUSHION_REG_W_RD        = sasanqua.core.cushion_reg_w_rd;
wire [31:0] CUSHION_REG_W_DATA      = sasanqua.core.cushion_reg_w_data;
wire        CUSHION_MEM_R_VALID     = sasanqua.core.cushion_mem_r_valid;
wire [4:0]  CUSHION_MEM_R_RD        = sasanqua.core.cushion_mem_r_rd;
wire [31:0] CUSHION_MEM_R_ADDR      = sasanqua.core.cushion_mem_r_addr;
wire [3:0]  CUSHION_MEM_R_STRB      = sasanqua.core.cushion_mem_r_strb;
wire        CUSHION_MEM_R_SIGNED    = sasanqua.core.cushion_mem_r_signed;
wire        CUSHION_MEM_W_VALID     = sasanqua.core.cushion_mem_w_valid;
wire [31:0] CUSHION_MEM_W_ADDR      = sasanqua.core.cushion_mem_w_addr;
wire [3:0]  CUSHION_MEM_W_STRB      = sasanqua.core.cushion_mem_w_strb;
wire [31:0] CUSHION_MEM_W_DATA      = sasanqua.core.cushion_mem_w_data;

// Core: Mem(r)
wire        MEMR_REG_W_VALID        = sasanqua.core.memr_reg_w_valid;
wire [4:0]  MEMR_REG_W_RD           = sasanqua.core.memr_reg_w_rd;
wire [31:0] MEMR_REG_W_DATA         = sasanqua.core.memr_reg_w_data;
wire        MEMR_MEM_W_VALID        = sasanqua.core.memr_mem_w_valid;
wire [31:0] MEMR_MEM_W_ADDR         = sasanqua.core.memr_mem_w_addr;
wire [3:0]  MEMR_MEM_W_STRB         = sasanqua.core.memr_mem_w_strb;
wire [31:0] MEMR_MEM_W_DATA         = sasanqua.core.memr_mem_w_data;

/* ----- テストベンチ本体 ----- */
initial begin
    RST = 0;
    #(STEP*10)

    // write_inst;
    write_rv32i_test_inst;

    RST = 1;
    #(STEP*10);

    RST = 0;
    #(STEP*10);

    #(STEP*4500);

    $stop;
end

endmodule

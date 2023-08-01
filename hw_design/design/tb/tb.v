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
wire [31:0] INST_RIADDR             = sasanqua.mmu.INST_RIADDR;
wire [31:0] INST_ROADDR             = sasanqua.mmu.INST_ROADDR;
wire        INST_RVALID             = sasanqua.mmu.INST_RVALID;
wire [31:0] INST_RDATA              = sasanqua.mmu.INST_RDATA;
wire        DATA_RDEN               = sasanqua.mmu.DATA_RDEN;
wire [31:0] DATA_RIADDR             = sasanqua.mmu.DATA_RIADDR;
wire [31:0] DATA_ROADDR             = sasanqua.mmu.DATA_ROADDR;
wire        DATA_RVALID             = sasanqua.mmu.DATA_RVALID;
wire [31:0] DATA_RDATA              = sasanqua.mmu.DATA_RDATA;
wire        DATA_WREN               = sasanqua.mmu.DATA_WREN;
wire [31:0] DATA_WADDR              = sasanqua.mmu.DATA_WADDR;
wire [31:0] DATA_WDATA              = sasanqua.mmu.DATA_WDATA;

// CSRs
wire        CSRS_RDEN               = sasanqua.csrs.RDEN;
wire [11:0] CSRS_RADDR              = sasanqua.csrs.RADDR;
wire        CSRS_RVALID             = sasanqua.csrs.RVALID;
wire [31:0] CSRS_RDATA              = sasanqua.csrs.RDATA;
wire        CSRS_WREN               = sasanqua.csrs.WREN;
wire [11:0] CSRS_WADDR              = sasanqua.csrs.WADDR;
wire [31:0] CSRS_WDATA              = sasanqua.csrs.WDATA;

// Core: Pipeline
wire        FLUSH                   = sasanqua.core.flush;
wire [31:0] NEW_PC                  = sasanqua.core.fetch.NEW_PC;
wire        STALL                   = sasanqua.core.stall;

// Core: Fetch
wire        INST_VALID              = sasanqua.core.inst_valid;
wire [31:0] INST_PC                 = sasanqua.core.inst_pc;
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
wire [4:0]  SCHEDULE_1ST_RS1        = sasanqua.core.reg_rs1;
wire [31:0] SCHEDULE_1ST_RS1_V      = sasanqua.core.reg_rs1_v;
wire [4:0]  SCHEDULE_1ST_RS2        = sasanqua.core.reg_rs2;
wire [31:0] SCHEDULE_1ST_RS2_V      = sasanqua.core.reg_rs2_v;
wire [2:0]  SCHEDULE_1ST_FUNCT3     = sasanqua.core.schedule_1st_funct3;
wire [6:0]  SCHEDULE_1ST_FUNCT7     = sasanqua.core.schedule_1st_funct7;
wire [31:0] SCHEDULE_1ST_IMM        = sasanqua.core.schedule_1st_imm;

// Core: Exec
wire [4:0]  EXEC_REG_W_RD           = sasanqua.core.reg_w_rd;
wire [31:0] EXEC_REG_W_DATA         = sasanqua.core.reg_w_data;
wire [11:0] EXEC_CSR_W_ADDR         = sasanqua.core.csr_w_addr;
wire [31:0] EXEC_CSR_W_DATA         = sasanqua.core.csr_w_data;
wire        EXEC_MEM_R_VALID        = sasanqua.core.mem_r_valid;
wire [4:0]  EXEC_MEM_R_RD           = sasanqua.core.mem_r_rd;
wire [31:0] EXEC_MEM_R_ADDR         = sasanqua.core.mem_r_addr;
wire [3:0]  EXEC_MEM_R_STRB         = sasanqua.core.mem_r_strb;
wire        EXEC_MEM_R_SIGNED       = sasanqua.core.mem_r_signed;
wire        EXEC_MEM_W_VALID        = sasanqua.core.mem_w_valid;
wire [31:0] EXEC_MEM_W_ADDR         = sasanqua.core.mem_w_addr;
wire [3:0]  EXEC_MEM_W_STRB         = sasanqua.core.mem_w_strb;
wire [31:0] EXEC_MEM_W_DATA         = sasanqua.core.mem_w_data;
wire        EXEC_JMP_DO             = sasanqua.core.jmp_do;
wire [31:0] EXEC_JMP_PC             = sasanqua.core.jmp_pc;

// Core: Cushion
wire [4:0]  CUSHION_REG_W_RD        = sasanqua.core.cushion_reg_w_rd;
wire [31:0] CUSHION_REG_W_DATA      = sasanqua.core.cushion_reg_w_data;
wire [11:0] CUSHION_CSR_W_ADDR      = sasanqua.core.cushion_csr_w_addr;
wire [31:0] CUSHION_CSR_W_DATA      = sasanqua.core.cushion_csr_w_data;
wire        CUSHION_MEM_R_VALID     = sasanqua.core.cushion_mem_r_valid;
wire [4:0]  CUSHION_MEM_R_RD        = sasanqua.core.cushion_mem_r_rd;
wire [31:0] CUSHION_MEM_R_ADDR      = sasanqua.core.cushion_mem_r_addr;
wire [3:0]  CUSHION_MEM_R_STRB      = sasanqua.core.cushion_mem_r_strb;
wire        CUSHION_MEM_R_SIGNED    = sasanqua.core.cushion_mem_r_signed;
wire        CUSHION_MEM_W_VALID     = sasanqua.core.cushion_mem_w_valid;
wire [31:0] CUSHION_MEM_W_ADDR      = sasanqua.core.cushion_mem_w_addr;
wire [3:0]  CUSHION_MEM_W_STRB      = sasanqua.core.cushion_mem_w_strb;
wire [31:0] CUSHION_MEM_W_DATA      = sasanqua.core.cushion_mem_w_data;
wire        CUSHION_JMP_DO          = sasanqua.core.cushion_jmp_do;
wire [31:0] CUSHION_JMP_PC          = sasanqua.core.cushion_jmp_pc;

// Core: Mem(r)
wire        MEMR_MEM_R_VALID        = sasanqua.core.memr_mem_r_valid;
wire [4:0]  MEMR_MEM_R_RD           = sasanqua.core.memr_mem_r_rd;
wire [31:0] MEMR_MEM_R_DATA         = sasanqua.core.memr_mem_r_data;
wire [4:0]  MEMR_REG_W_RD           = sasanqua.core.memr_reg_w_rd;
wire [31:0] MEMR_REG_W_DATA         = sasanqua.core.memr_reg_w_data;
wire [11:0] MEMR_CSR_W_ADDR         = sasanqua.core.memr_csr_w_addr;
wire [31:0] MEMR_CSR_W_DATA         = sasanqua.core.memr_csr_w_data;
wire        MEMR_MEM_W_VALID        = sasanqua.core.memr_mem_w_valid;
wire [31:0] MEMR_MEM_W_ADDR         = sasanqua.core.memr_mem_w_addr;
wire [3:0]  MEMR_MEM_W_STRB         = sasanqua.core.memr_mem_w_strb;
wire [31:0] MEMR_MEM_W_DATA         = sasanqua.core.memr_mem_w_data;
wire        MEMR_JMP_DO             = sasanqua.core.memr_jmp_do;
wire [31:0] MEMR_JMP_PC             = sasanqua.core.memr_jmp_pc;

// Register: rv32i
wire [31:0] I_REG_0                 = sasanqua.core.register.register[0];
wire [31:0] I_REG_1                 = sasanqua.core.register.register[1];
wire [31:0] I_REG_2                 = sasanqua.core.register.register[2];
wire [31:0] I_REG_3                 = sasanqua.core.register.register[3];
wire [31:0] I_REG_4                 = sasanqua.core.register.register[4];
wire [31:0] I_REG_5                 = sasanqua.core.register.register[5];
wire [31:0] I_REG_6                 = sasanqua.core.register.register[6];
wire [31:0] I_REG_7                 = sasanqua.core.register.register[7];
wire [31:0] I_REG_8                 = sasanqua.core.register.register[8];
wire [31:0] I_REG_9                 = sasanqua.core.register.register[9];
wire [31:0] I_REG_10                = sasanqua.core.register.register[10];
wire [31:0] I_REG_11                = sasanqua.core.register.register[11];
wire [31:0] I_REG_12                = sasanqua.core.register.register[12];
wire [31:0] I_REG_13                = sasanqua.core.register.register[13];
wire [31:0] I_REG_14                = sasanqua.core.register.register[14];
wire [31:0] I_REG_15                = sasanqua.core.register.register[15];
wire [31:0] I_REG_16                = sasanqua.core.register.register[16];
wire [31:0] I_REG_17                = sasanqua.core.register.register[17];
wire [31:0] I_REG_18                = sasanqua.core.register.register[18];
wire [31:0] I_REG_19                = sasanqua.core.register.register[19];
wire [32:0] I_REG_20                = sasanqua.core.register.register[20];
wire [32:0] I_REG_21                = sasanqua.core.register.register[21];
wire [32:0] I_REG_22                = sasanqua.core.register.register[22];
wire [32:0] I_REG_23                = sasanqua.core.register.register[23];
wire [32:0] I_REG_24                = sasanqua.core.register.register[24];
wire [32:0] I_REG_25                = sasanqua.core.register.register[25];
wire [32:0] I_REG_26                = sasanqua.core.register.register[26];
wire [32:0] I_REG_27                = sasanqua.core.register.register[27];
wire [32:0] I_REG_28                = sasanqua.core.register.register[28];
wire [32:0] I_REG_29                = sasanqua.core.register.register[29];
wire [32:0] I_REG_30                = sasanqua.core.register.register[30];
wire [32:0] I_REG_31                = sasanqua.core.register.register[31];

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

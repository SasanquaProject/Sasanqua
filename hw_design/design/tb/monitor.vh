// Mem
wire        MEM_WAIT                = sasanqua.mem.MEM_WAIT;
wire        INST_RDEN               = sasanqua.mem.INST_RDEN;
wire [31:0] INST_RIADDR             = sasanqua.mem.INST_RIADDR;
wire [31:0] INST_ROADDR             = sasanqua.mem.INST_ROADDR;
wire        INST_RVALID             = sasanqua.mem.INST_RVALID;
wire [31:0] INST_RDATA              = sasanqua.mem.INST_RDATA;
wire        DATA_RDEN               = sasanqua.mem.DATA_RDEN;
wire [31:0] DATA_RIADDR             = sasanqua.mem.DATA_RIADDR;
wire [31:0] DATA_ROADDR             = sasanqua.mem.DATA_ROADDR;
wire        DATA_RVALID             = sasanqua.mem.DATA_RVALID;
wire [31:0] DATA_RDATA              = sasanqua.mem.DATA_RDATA;
wire        DATA_WREN               = sasanqua.mem.DATA_WREN;
wire [3:0]  DATA_WSTRB              = sasanqua.mem.DATA_WSTRB;
wire [31:0] DATA_WADDR              = sasanqua.mem.DATA_WADDR;
wire [31:0] DATA_WDATA              = sasanqua.mem.DATA_WDATA;

// CLINT
wire [31:0] CLINT_MTIME             = sasanqua.clint.mtime[0];
wire [31:0] CLINT_MTIMECMP          = sasanqua.clint.mtimecmp[0];
wire        CLINT_INT_EN            = sasanqua.clint.INT_EN;
wire [3:0]  CLINT_INT_CODE          = sasanqua.clint.INT_CODE;

// Core: Status
wire        INT_ALLOW               = sasanqua.core.main.int_allow;

// Core: Pipeline
wire        FLUSH                   = sasanqua.core.main.flush;
wire [31:0] FLUSH_PC                = sasanqua.core.main.flush_pc;
wire        STALL                   = sasanqua.core.main.stall;

// Core: Fetch
wire [31:0] FETCH_PC                = sasanqua.core.main.fetch_pc;
wire [31:0] FETCH_INST              = sasanqua.core.main.fetch_inst;

// Core: Decode
wire [31:0] DECODE_PC               = sasanqua.core.main.decode_pc;
wire [6:0]  DECODE_OPCODE           = sasanqua.core.main.decode_opcode;
wire [4:0]  DECODE_RD               = sasanqua.core.main.decode_rd;
wire [4:0]  DECODE_RS1              = sasanqua.core.main.decode_rs1;
wire [4:0]  DECODE_RS2              = sasanqua.core.main.decode_rs2;
wire [31:0] DECODE_IMM              = sasanqua.core.main.decode_imm;

// Core: Pool
wire [31:0] POOL_PC                 = sasanqua.core.main.pool_pc;
wire [6:0]  POOL_OPCODE             = sasanqua.core.main.pool_opcode;
wire [4:0]  POOL_RD                 = sasanqua.core.main.pool_rd;
wire [4:0]  POOL_RS1                = sasanqua.core.main.pool_rs1;
wire [4:0]  POOL_RS2                = sasanqua.core.main.pool_rs2;
wire [11:0] POOL_CSR                = sasanqua.core.main.pool_csr;
wire [31:0] POOL_IMM                = sasanqua.core.main.pool_imm;

// Core: Check
wire [31:0] CHECK_PC                = sasanqua.core.main.check_pc;
wire [6:0]  CHECK_OPCODE            = sasanqua.core.main.check_opcode;
wire [4:0]  CHECK_RD                = sasanqua.core.main.check_rd;
wire [4:0]  CHECK_RS1               = sasanqua.core.main.check_rs1;
wire [4:0]  CHECK_RS2               = sasanqua.core.main.check_rs2;
wire [11:0] CHECK_CSR               = sasanqua.core.main.check_csr;
wire [31:0] CHECK_IMM               = sasanqua.core.main.check_imm;

// Core: Schedule, Register(r)
wire [1:0]  SCHEDULE_ALLOW          = {
    sasanqua.core.main.schedule_b_allow,
    sasanqua.core.main.schedule_a_allow
};

wire [31:0] SCHEDULE_A_PC           = sasanqua.core.main.schedule_a_pc;
wire [4:0]  SCHEDULE_A_RD_ADDR      = sasanqua.core.main.schedule_a_rd;
wire        SCHEDULE_A_RS1_VALID    = sasanqua.core.main.schedule_a_rs1_valid;
wire [4:0]  SCHEDULE_A_RS1_ADDR     = sasanqua.core.main.schedule_a_rs1;
wire [31:0] SCHEDULE_A_RS1_DATA     = sasanqua.core.main.schedule_a_rs1_data;
wire        SCHEDULE_A_RS2_VALID    = sasanqua.core.main.schedule_a_rs2_valid;
wire [4:0]  SCHEDULE_A_RS2_ADDR     = sasanqua.core.main.schedule_a_rs2;
wire [31:0] SCHEDULE_A_RS2_DATA     = sasanqua.core.main.schedule_a_rs2_data;
wire        SCHEDULE_A_CSR_VALID    = sasanqua.core.main.schedule_a_csr_valid;
wire [11:0] SCHEDULE_A_CSR_ADDR     = sasanqua.core.main.schedule_a_csr;
wire [31:0] SCHEDULE_A_CSR_DATA     = sasanqua.core.main.schedule_a_csr_data;
wire [31:0] SCHEDULE_A_IMM          = sasanqua.core.main.schedule_a_imm;

wire [31:0] SCHEDULE_B_PC           = sasanqua.core.main.sasanqua_cop.pc[1];
wire [4:0]  SCHEDULE_B_RD_ADDR      = sasanqua.core.main.sasanqua_cop.rd[1];
wire        SCHEDULE_B_RS1_VALID    = sasanqua.core.main.schedule_b_rs1_valid;
wire [4:0]  SCHEDULE_B_RS1_ADDR     = sasanqua.core.main.cop_c_rs1;
wire [31:0] SCHEDULE_B_RS1_DATA     = sasanqua.core.main.schedule_b_rs1_data;
wire        SCHEDULE_B_RS2_VALID    = sasanqua.core.main.schedule_b_rs2_valid;
wire [4:0]  SCHEDULE_B_RS2_ADDR     = sasanqua.core.main.cop_c_rs2;
wire [31:0] SCHEDULE_B_RS2_DATA     = sasanqua.core.main.schedule_b_rs2_data;
wire [31:0] SCHEDULE_B_IMM          = sasanqua.core.main.sasanqua_cop.imm[1];

// Core: Exec
wire        EXEC_A_ALLOW            = sasanqua.core.main.exec_allow;
wire        EXEC_A_VALID            = sasanqua.core.main.exec_valid;
wire [31:0] EXEC_A_PC               = sasanqua.core.main.exec_pc;
wire        EXEC_A_REG_W_EN         = sasanqua.core.main.exec_reg_w_en;
wire [4:0]  EXEC_A_REG_W_RD         = sasanqua.core.main.exec_reg_w_rd;
wire [31:0] EXEC_A_REG_W_DATA       = sasanqua.core.main.exec_reg_w_data;
wire [11:0] EXEC_A_CSR_W_ADDR       = sasanqua.core.main.exec_csr_w_addr;
wire [31:0] EXEC_A_CSR_W_DATA       = sasanqua.core.main.exec_csr_w_data;
wire        EXEC_A_MEM_R_EN         = sasanqua.core.main.exec_mem_r_en;
wire [4:0]  EXEC_A_MEM_R_RD         = sasanqua.core.main.exec_mem_r_rd;
wire [31:0] EXEC_A_MEM_R_ADDR       = sasanqua.core.main.exec_mem_r_addr;
wire [3:0]  EXEC_A_MEM_R_STRB       = sasanqua.core.main.exec_mem_r_strb;
wire        EXEC_A_MEM_R_SIGNED     = sasanqua.core.main.exec_mem_r_signed;
wire        EXEC_A_MEM_W_EN         = sasanqua.core.main.exec_mem_w_en;
wire [31:0] EXEC_A_MEM_W_ADDR       = sasanqua.core.main.exec_mem_w_addr;
wire [3:0]  EXEC_A_MEM_W_STRB       = sasanqua.core.main.exec_mem_w_strb;
wire [31:0] EXEC_A_MEM_W_DATA       = sasanqua.core.main.exec_mem_w_data;
wire        EXEC_A_JMP_DO           = sasanqua.core.main.exec_jmp_do;
wire [31:0] EXEC_A_JMP_PC           = sasanqua.core.main.exec_jmp_pc;
wire        EXEC_A_EXC_EN           = sasanqua.core.main.exec_exc_en;
wire [3:0]  EXEC_A_EXC_CODE         = sasanqua.core.main.exec_exc_code;

wire        EXEC_B_ALLOW            = sasanqua.core.main.cop_e_allow;
wire        EXEC_B_VALID            = sasanqua.core.main.cop_e_valid;
wire [31:0] EXEC_B_PC               = sasanqua.core.main.cop_e_pc;
wire        EXEC_B_REG_W_EN         = sasanqua.core.main.cop_e_reg_w_en;
wire [4:0]  EXEC_B_REG_W_RD         = sasanqua.core.main.cop_e_reg_w_rd;
wire [31:0] EXEC_B_REG_W_DAT        = sasanqua.core.main.cop_e_reg_w_data;
wire        EXEC_B_EXC_EN           = sasanqua.core.main.cop_e_exc_en;
wire [3:0]  EXEC_B_EXC_CODE         = sasanqua.core.main.cop_e_exc_code;

// Core: Cushion
wire [31:0] CUSHION_PC              = sasanqua.core.main.cushion_pc;
wire [4:0]  CUSHION_REG_W_RD        = sasanqua.core.main.cushion_reg_w_rd;
wire [31:0] CUSHION_REG_W_DATA      = sasanqua.core.main.cushion_reg_w_data;
wire [11:0] CUSHION_CSR_W_ADDR      = sasanqua.core.main.cushion_csr_w_addr;
wire [31:0] CUSHION_CSR_W_DATA      = sasanqua.core.main.cushion_csr_w_data;
wire        CUSHION_MEM_R_EN        = sasanqua.core.main.cushion_mem_r_en;
wire [4:0]  CUSHION_MEM_R_RD        = sasanqua.core.main.cushion_mem_r_rd;
wire [31:0] CUSHION_MEM_R_ADDR      = sasanqua.core.main.cushion_mem_r_addr;
wire [3:0]  CUSHION_MEM_R_STRB      = sasanqua.core.main.cushion_mem_r_strb;
wire        CUSHION_MEM_R_SIGNED    = sasanqua.core.main.cushion_mem_r_signed;
wire        CUSHION_MEM_W_EN        = sasanqua.core.main.cushion_mem_w_en;
wire [31:0] CUSHION_MEM_W_ADDR      = sasanqua.core.main.cushion_mem_w_addr;
wire [3:0]  CUSHION_MEM_W_STRB      = sasanqua.core.main.cushion_mem_w_strb;
wire [31:0] CUSHION_MEM_W_DATA      = sasanqua.core.main.cushion_mem_w_data;
wire        CUSHION_JMP_DO          = sasanqua.core.main.cushion_jmp_do;
wire [31:0] CUSHION_JMP_PC          = sasanqua.core.main.cushion_jmp_pc;
wire        CUSHION_EXC_EN          = sasanqua.core.main.cushion_exc_en;
wire [3:0]  CUSHION_EXC_CODE        = sasanqua.core.main.cushion_exc_code;

// Core: Mem(r)
wire [4:0]  MEMR_REG_W_RD           = sasanqua.core.main.memr_reg_w_rd;
wire [31:0] MEMR_REG_W_DATA         = sasanqua.core.main.memr_reg_w_data;
wire [11:0] MEMR_CSR_W_ADDR         = sasanqua.core.main.memr_csr_w_addr;
wire [31:0] MEMR_CSR_W_DATA         = sasanqua.core.main.memr_csr_w_data;
wire        MEMR_MEM_W_EN           = sasanqua.core.main.memr_mem_w_en;
wire [31:0] MEMR_MEM_W_ADDR         = sasanqua.core.main.memr_mem_w_addr;
wire [31:0] MEMR_MEM_W_DATA         = sasanqua.core.main.memr_mem_w_data;
wire        MEMR_JMP_DO             = sasanqua.core.main.memr_jmp_do;
wire [31:0] MEMR_JMP_PC             = sasanqua.core.main.memr_jmp_pc;

// Core: Trap
wire [31:0] TRAP_PC                 = sasanqua.core.main.trap_pc;
wire        TRAP_EN                 = sasanqua.core.main.trap_en;
wire [31:0] TRAP_CODE               = sasanqua.core.main.trap_code;

// Register: rv32i
wire [31:0] I_REG_0                 = sasanqua.core.main.reg_std_rv32i_0.registers[0];
wire [31:0] I_REG_1                 = sasanqua.core.main.reg_std_rv32i_0.registers[1];
wire [31:0] I_REG_2                 = sasanqua.core.main.reg_std_rv32i_0.registers[2];
wire [31:0] I_REG_3                 = sasanqua.core.main.reg_std_rv32i_0.registers[3];
wire [31:0] I_REG_4                 = sasanqua.core.main.reg_std_rv32i_0.registers[4];
wire [31:0] I_REG_5                 = sasanqua.core.main.reg_std_rv32i_0.registers[5];
wire [31:0] I_REG_6                 = sasanqua.core.main.reg_std_rv32i_0.registers[6];
wire [31:0] I_REG_7                 = sasanqua.core.main.reg_std_rv32i_0.registers[7];
wire [31:0] I_REG_8                 = sasanqua.core.main.reg_std_rv32i_0.registers[8];
wire [31:0] I_REG_9                 = sasanqua.core.main.reg_std_rv32i_0.registers[9];
wire [31:0] I_REG_10                = sasanqua.core.main.reg_std_rv32i_0.registers[10];
wire [31:0] I_REG_11                = sasanqua.core.main.reg_std_rv32i_0.registers[11];
wire [31:0] I_REG_12                = sasanqua.core.main.reg_std_rv32i_0.registers[12];
wire [31:0] I_REG_13                = sasanqua.core.main.reg_std_rv32i_0.registers[13];
wire [31:0] I_REG_14                = sasanqua.core.main.reg_std_rv32i_0.registers[14];
wire [31:0] I_REG_15                = sasanqua.core.main.reg_std_rv32i_0.registers[15];
wire [31:0] I_REG_16                = sasanqua.core.main.reg_std_rv32i_0.registers[16];
wire [31:0] I_REG_17                = sasanqua.core.main.reg_std_rv32i_0.registers[17];
wire [31:0] I_REG_18                = sasanqua.core.main.reg_std_rv32i_0.registers[18];
wire [31:0] I_REG_19                = sasanqua.core.main.reg_std_rv32i_0.registers[19];
wire [32:0] I_REG_20                = sasanqua.core.main.reg_std_rv32i_0.registers[20];
wire [32:0] I_REG_21                = sasanqua.core.main.reg_std_rv32i_0.registers[21];
wire [32:0] I_REG_22                = sasanqua.core.main.reg_std_rv32i_0.registers[22];
wire [32:0] I_REG_23                = sasanqua.core.main.reg_std_rv32i_0.registers[23];
wire [32:0] I_REG_24                = sasanqua.core.main.reg_std_rv32i_0.registers[24];
wire [32:0] I_REG_25                = sasanqua.core.main.reg_std_rv32i_0.registers[25];
wire [32:0] I_REG_26                = sasanqua.core.main.reg_std_rv32i_0.registers[26];
wire [32:0] I_REG_27                = sasanqua.core.main.reg_std_rv32i_0.registers[27];
wire [32:0] I_REG_28                = sasanqua.core.main.reg_std_rv32i_0.registers[28];
wire [32:0] I_REG_29                = sasanqua.core.main.reg_std_rv32i_0.registers[29];
wire [32:0] I_REG_30                = sasanqua.core.main.reg_std_rv32i_0.registers[30];
wire [32:0] I_REG_31                = sasanqua.core.main.reg_std_rv32i_0.registers[31];

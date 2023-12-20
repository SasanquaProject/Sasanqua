// Mem
wire        MEM_WAIT                = sasanqua.mem.MEM_WAIT;

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

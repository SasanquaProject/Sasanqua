`timescale 1ns/1ps

module sasanqua_tb;

/* ----- 各種定数 ----- */
localparam integer C_AXI_DATA_WIDTH = 32;
localparam integer C_OFFSET_WIDTH   = 16;
localparam integer STEP             = 1000 / 100;   // 100Mhz

/* ----- クロック ----- */
reg CLK;
reg RST;

always begin
    CLK = 0; #(STEP/2);
    CLK = 1; #(STEP/2);
end

/* ----- BFM との接続 ----- */
`include "./axi/setup.vh"

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

// Core: Pipeline
wire        FLUSH                   = sasanqua.core.flush;
wire [31:0] NEW_PC                  = sasanqua.core.fetch.NEW_PC;
wire        STALL                   = sasanqua.core.stall;

// Core: Fetch
wire [31:0] INST_PC                 = sasanqua.core.inst_pc;
wire [31:0] INST_DATA               = sasanqua.core.inst_data;

// Core: Decode 1st
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
wire [31:0] DECODE_2ND_PC           = sasanqua.core.decode_2nd_pc;
wire [6:0]  DECODE_2ND_OPCODE       = sasanqua.core.decode_2nd_opcode;
wire [4:0]  DECODE_2ND_RD           = sasanqua.core.decode_2nd_rd;
wire [4:0]  DECODE_2ND_RS1          = sasanqua.core.decode_2nd_rs1;
wire [4:0]  DECODE_2ND_RS2          = sasanqua.core.decode_2nd_rs2;
wire [11:0] DECODE_2ND_CSR          = sasanqua.core.decode_2nd_csr;
wire [2:0]  DECODE_2ND_FUNCT3       = sasanqua.core.decode_2nd_funct3;
wire [6:0]  DECODE_2ND_FUNCT7       = sasanqua.core.decode_2nd_funct7;
wire [31:0] DECODE_2ND_IMM          = sasanqua.core.decode_2nd_imm;

// Core: Schedule 1st, Register(r)
wire [31:0] SCHEDULE_1ST_PC         = sasanqua.core.schedule_1st_pc;
wire [6:0]  SCHEDULE_1ST_OPCODE     = sasanqua.core.schedule_1st_opcode;
wire [4:0]  SCHEDULE_1ST_RD_ADDR    = sasanqua.core.schedule_1st_rd;
wire        SCHEDULE_1ST_RS1_VALID  = sasanqua.core.reg_rs1_valid;
wire [4:0]  SCHEDULE_1ST_RS1_ADDR   = sasanqua.core.reg_rs1_addr;
wire [31:0] SCHEDULE_1ST_RS1_DATA   = sasanqua.core.reg_rs1_data;
wire        SCHEDULE_1ST_RS2_VALID  = sasanqua.core.reg_rs2_valid;
wire [4:0]  SCHEDULE_1ST_RS2_ADDR   = sasanqua.core.reg_rs2_addr;
wire [31:0] SCHEDULE_1ST_RS2_DATA   = sasanqua.core.reg_rs2_data;
wire        SCHEDULE_1ST_CSR_VALID  = sasanqua.core.reg_csr_valid;
wire [11:0] SCHEDULE_1ST_CSR_ADDR   = sasanqua.core.reg_csr_addr;
wire [31:0] SCHEDULE_1ST_CSR_DATA   = sasanqua.core.reg_csr_data;
wire [2:0]  SCHEDULE_1ST_FUNCT3     = sasanqua.core.schedule_1st_funct3;
wire [6:0]  SCHEDULE_1ST_FUNCT7     = sasanqua.core.schedule_1st_funct7;
wire [31:0] SCHEDULE_1ST_IMM        = sasanqua.core.schedule_1st_imm;

// Core: Exec
wire [4:0]  EXEC_REG_W_RD           = sasanqua.core.reg_w_rd;
wire [31:0] EXEC_REG_W_DATA         = sasanqua.core.reg_w_data;
wire [11:0] EXEC_CSR_W_ADDR         = sasanqua.core.csr_w_addr;
wire [31:0] EXEC_CSR_W_DATA         = sasanqua.core.csr_w_data;
wire        EXEC_MEM_R_EN           = sasanqua.core.mem_r_en;
wire [4:0]  EXEC_MEM_R_RD           = sasanqua.core.mem_r_rd;
wire [31:0] EXEC_MEM_R_ADDR         = sasanqua.core.mem_r_addr;
wire [3:0]  EXEC_MEM_R_STRB         = sasanqua.core.mem_r_strb;
wire        EXEC_MEM_R_SIGNED       = sasanqua.core.mem_r_signed;
wire        EXEC_MEM_W_EN           = sasanqua.core.mem_w_en;
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
wire        CUSHION_MEM_R_EN        = sasanqua.core.cushion_mem_r_en;
wire [4:0]  CUSHION_MEM_R_RD        = sasanqua.core.cushion_mem_r_rd;
wire [31:0] CUSHION_MEM_R_ADDR      = sasanqua.core.cushion_mem_r_addr;
wire [3:0]  CUSHION_MEM_R_STRB      = sasanqua.core.cushion_mem_r_strb;
wire        CUSHION_MEM_R_SIGNED    = sasanqua.core.cushion_mem_r_signed;
wire        CUSHION_MEM_W_EN        = sasanqua.core.cushion_mem_w_en;
wire [31:0] CUSHION_MEM_W_ADDR      = sasanqua.core.cushion_mem_w_addr;
wire [3:0]  CUSHION_MEM_W_STRB      = sasanqua.core.cushion_mem_w_strb;
wire [31:0] CUSHION_MEM_W_DATA      = sasanqua.core.cushion_mem_w_data;
wire        CUSHION_JMP_DO          = sasanqua.core.cushion_jmp_do;
wire [31:0] CUSHION_JMP_PC          = sasanqua.core.cushion_jmp_pc;

// Core: Mem(r)
wire [4:0]  MEMR_REG_W_RD           = sasanqua.core.memr_reg_w_rd;
wire [31:0] MEMR_REG_W_DATA         = sasanqua.core.memr_reg_w_data;
wire [11:0] MEMR_CSR_W_ADDR         = sasanqua.core.memr_csr_w_addr;
wire [31:0] MEMR_CSR_W_DATA         = sasanqua.core.memr_csr_w_data;
wire        MEMR_MEM_W_EN           = sasanqua.core.memr_mem_w_en;
wire [31:0] MEMR_MEM_W_ADDR         = sasanqua.core.memr_mem_w_addr;
wire [31:0] MEMR_MEM_W_DATA         = sasanqua.core.memr_mem_w_data;
wire        MEMR_JMP_DO             = sasanqua.core.memr_jmp_do;
wire [31:0] MEMR_JMP_PC             = sasanqua.core.memr_jmp_pc;

// Register: rv32i
wire [31:0] I_REG_0                 = sasanqua.core.reg_std_rv32i_0.registers[0];
wire [31:0] I_REG_1                 = sasanqua.core.reg_std_rv32i_0.registers[1];
wire [31:0] I_REG_2                 = sasanqua.core.reg_std_rv32i_0.registers[2];
wire [31:0] I_REG_3                 = sasanqua.core.reg_std_rv32i_0.registers[3];
wire [31:0] I_REG_4                 = sasanqua.core.reg_std_rv32i_0.registers[4];
wire [31:0] I_REG_5                 = sasanqua.core.reg_std_rv32i_0.registers[5];
wire [31:0] I_REG_6                 = sasanqua.core.reg_std_rv32i_0.registers[6];
wire [31:0] I_REG_7                 = sasanqua.core.reg_std_rv32i_0.registers[7];
wire [31:0] I_REG_8                 = sasanqua.core.reg_std_rv32i_0.registers[8];
wire [31:0] I_REG_9                 = sasanqua.core.reg_std_rv32i_0.registers[9];
wire [31:0] I_REG_10                = sasanqua.core.reg_std_rv32i_0.registers[10];
wire [31:0] I_REG_11                = sasanqua.core.reg_std_rv32i_0.registers[11];
wire [31:0] I_REG_12                = sasanqua.core.reg_std_rv32i_0.registers[12];
wire [31:0] I_REG_13                = sasanqua.core.reg_std_rv32i_0.registers[13];
wire [31:0] I_REG_14                = sasanqua.core.reg_std_rv32i_0.registers[14];
wire [31:0] I_REG_15                = sasanqua.core.reg_std_rv32i_0.registers[15];
wire [31:0] I_REG_16                = sasanqua.core.reg_std_rv32i_0.registers[16];
wire [31:0] I_REG_17                = sasanqua.core.reg_std_rv32i_0.registers[17];
wire [31:0] I_REG_18                = sasanqua.core.reg_std_rv32i_0.registers[18];
wire [31:0] I_REG_19                = sasanqua.core.reg_std_rv32i_0.registers[19];
wire [32:0] I_REG_20                = sasanqua.core.reg_std_rv32i_0.registers[20];
wire [32:0] I_REG_21                = sasanqua.core.reg_std_rv32i_0.registers[21];
wire [32:0] I_REG_22                = sasanqua.core.reg_std_rv32i_0.registers[22];
wire [32:0] I_REG_23                = sasanqua.core.reg_std_rv32i_0.registers[23];
wire [32:0] I_REG_24                = sasanqua.core.reg_std_rv32i_0.registers[24];
wire [32:0] I_REG_25                = sasanqua.core.reg_std_rv32i_0.registers[25];
wire [32:0] I_REG_26                = sasanqua.core.reg_std_rv32i_0.registers[26];
wire [32:0] I_REG_27                = sasanqua.core.reg_std_rv32i_0.registers[27];
wire [32:0] I_REG_28                = sasanqua.core.reg_std_rv32i_0.registers[28];
wire [32:0] I_REG_29                = sasanqua.core.reg_std_rv32i_0.registers[29];
wire [32:0] I_REG_30                = sasanqua.core.reg_std_rv32i_0.registers[30];
wire [32:0] I_REG_31                = sasanqua.core.reg_std_rv32i_0.registers[31];

/* ----- riscv-tests用タスク ----- */
task riscv_tests;
input integer id, fd;
begin
    write_inst(fd);

    RST = 1;
    #(STEP*10)
    RST = 0;

    @(posedge MEMR_JMP_PC == 32'h2000_003C);
    #(STEP*10)

    if (I_REG_3 == 32'b1)
        $display("%d: Success", id);
    else
        $display("%d: Failed (at %d)", id, I_REG_3 >> 1);
end
endtask

/* ----- テストベンチ本体 ----- */
integer fd;
initial begin
    RST = 0;

    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-add.bin", "rb");        riscv_tests( 0, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-addi.bin", "rb");       riscv_tests( 1, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-and.bin", "rb");        riscv_tests( 2, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-andi.bin", "rb");       riscv_tests( 3, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-auipc.bin", "rb");      riscv_tests( 4, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-beq.bin", "rb");        riscv_tests( 5, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-bge.bin", "rb");        riscv_tests( 6, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-bgeu.bin", "rb");       riscv_tests( 7, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-blt.bin", "rb");        riscv_tests( 8, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-bltu.bin", "rb");       riscv_tests( 9, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-bne.bin", "rb");        riscv_tests(10, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-jal.bin", "rb");        riscv_tests(11, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-jalr.bin", "rb");       riscv_tests(12, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-lb.bin", "rb");         riscv_tests(13, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-lbu.bin", "rb");        riscv_tests(14, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-lh.bin", "rb");         riscv_tests(15, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-lhu.bin", "rb");        riscv_tests(16, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-lui.bin", "rb");        riscv_tests(17, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-lw.bin", "rb");         riscv_tests(18, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-or.bin", "rb");         riscv_tests(19, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-ori.bin", "rb");        riscv_tests(20, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-sb.bin", "rb");         riscv_tests(21, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-sh.bin", "rb");         riscv_tests(22, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-sll.bin", "rb");        riscv_tests(23, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-slli.bin", "rb");       riscv_tests(24, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-slt.bin", "rb");        riscv_tests(25, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-slti.bin", "rb");       riscv_tests(26, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-sltiu.bin", "rb");      riscv_tests(27, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-sltu.bin", "rb");       riscv_tests(28, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-sra.bin", "rb");        riscv_tests(29, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-srai.bin", "rb");       riscv_tests(30, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-srl.bin", "rb");        riscv_tests(31, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-srli.bin", "rb");       riscv_tests(32, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-sub.bin", "rb");        riscv_tests(33, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-sw.bin", "rb");         riscv_tests(34, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-xor.bin", "rb");        riscv_tests(35, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-xori.bin", "rb");       riscv_tests(36, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-fence_i.bin", "rb");    riscv_tests(37, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/bin/rv32ui-p-simple.bin", "rb");     riscv_tests(38, fd);

    $stop;
end

endmodule

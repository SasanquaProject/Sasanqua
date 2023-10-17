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
`include "./monitor.vh"
// `include "./monitor_simple.vh"

/* ----- riscv-tests用タスク ----- */
task riscv_tests;
input integer id, fd;
begin
    write_inst(fd);

    RST = 1;
    #(STEP*10)
    RST = 0;

    @(FLUSH && FLUSH_PC == 32'h2000_003C);
    #(STEP*10)
    // #(STEP * 100000)

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

    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-add.bin", "rb");        riscv_tests( 0, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-addi.bin", "rb");       riscv_tests( 1, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-and.bin", "rb");        riscv_tests( 2, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-andi.bin", "rb");       riscv_tests( 3, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-auipc.bin", "rb");      riscv_tests( 4, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-beq.bin", "rb");        riscv_tests( 5, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-bge.bin", "rb");        riscv_tests( 6, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-bgeu.bin", "rb");       riscv_tests( 7, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-blt.bin", "rb");        riscv_tests( 8, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-bltu.bin", "rb");       riscv_tests( 9, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-bne.bin", "rb");        riscv_tests(10, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-jal.bin", "rb");        riscv_tests(11, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-jalr.bin", "rb");       riscv_tests(12, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-lb.bin", "rb");         riscv_tests(13, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-lbu.bin", "rb");        riscv_tests(14, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-lh.bin", "rb");         riscv_tests(15, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-lhu.bin", "rb");        riscv_tests(16, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-lui.bin", "rb");        riscv_tests(17, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-lw.bin", "rb");         riscv_tests(18, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-or.bin", "rb");         riscv_tests(19, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-ori.bin", "rb");        riscv_tests(20, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-sb.bin", "rb");         riscv_tests(21, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-sh.bin", "rb");         riscv_tests(22, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-sll.bin", "rb");        riscv_tests(23, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-slli.bin", "rb");       riscv_tests(24, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-slt.bin", "rb");        riscv_tests(25, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-slti.bin", "rb");       riscv_tests(26, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-sltiu.bin", "rb");      riscv_tests(27, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-sltu.bin", "rb");       riscv_tests(28, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-sra.bin", "rb");        riscv_tests(29, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-srai.bin", "rb");       riscv_tests(30, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-srl.bin", "rb");        riscv_tests(31, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-srli.bin", "rb");       riscv_tests(32, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-sub.bin", "rb");        riscv_tests(33, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-sw.bin", "rb");         riscv_tests(34, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-xor.bin", "rb");        riscv_tests(35, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-xori.bin", "rb");       riscv_tests(36, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-fence_i.bin", "rb");    riscv_tests(37, fd);
    fd = $fopen("../../../../../../design/tb/resources/riscv-tests/out/bin/rv32ui-p-simple.bin", "rb");     riscv_tests(38, fd);

    $stop;
end

endmodule

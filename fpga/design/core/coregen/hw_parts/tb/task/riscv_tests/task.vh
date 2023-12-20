/* ----- 成功判定タスク ----- */
task check_ok;
input integer fd, id;
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

/* ----- riscv-tests 実行タスク ----- */
task test;
integer fd;
begin
    RST = 0;

    fd = $fopen("rv32ui-p-add.bin", "rb");      check_ok(fd,  0);
    fd = $fopen("rv32ui-p-addi.bin", "rb");     check_ok(fd,  1);
    fd = $fopen("rv32ui-p-and.bin", "rb");      check_ok(fd,  2);
    fd = $fopen("rv32ui-p-andi.bin", "rb");     check_ok(fd,  3);
    fd = $fopen("rv32ui-p-auipc.bin", "rb");    check_ok(fd,  4);
    fd = $fopen("rv32ui-p-beq.bin", "rb");      check_ok(fd,  5);
    fd = $fopen("rv32ui-p-bge.bin", "rb");      check_ok(fd,  6);
    fd = $fopen("rv32ui-p-bgeu.bin", "rb");     check_ok(fd,  7);
    fd = $fopen("rv32ui-p-blt.bin", "rb");      check_ok(fd,  8);
    fd = $fopen("rv32ui-p-bltu.bin", "rb");     check_ok(fd,  9);
    fd = $fopen("rv32ui-p-bne.bin", "rb");      check_ok(fd, 10);
    fd = $fopen("rv32ui-p-jal.bin", "rb");      check_ok(fd, 11);
    fd = $fopen("rv32ui-p-jalr.bin", "rb");     check_ok(fd, 12);
    fd = $fopen("rv32ui-p-lb.bin", "rb");       check_ok(fd, 13);
    fd = $fopen("rv32ui-p-lbu.bin", "rb");      check_ok(fd, 14);
    fd = $fopen("rv32ui-p-lh.bin", "rb");       check_ok(fd, 15);
    fd = $fopen("rv32ui-p-lhu.bin", "rb");      check_ok(fd, 16);
    fd = $fopen("rv32ui-p-lui.bin", "rb");      check_ok(fd, 17);
    fd = $fopen("rv32ui-p-lw.bin", "rb");       check_ok(fd, 18);
    fd = $fopen("rv32ui-p-or.bin", "rb");       check_ok(fd, 19);
    fd = $fopen("rv32ui-p-ori.bin", "rb");      check_ok(fd, 20);
    fd = $fopen("rv32ui-p-sb.bin", "rb");       check_ok(fd, 21);
    fd = $fopen("rv32ui-p-sh.bin", "rb");       check_ok(fd, 22);
    fd = $fopen("rv32ui-p-sll.bin", "rb");      check_ok(fd, 23);
    fd = $fopen("rv32ui-p-slli.bin", "rb");     check_ok(fd, 24);
    fd = $fopen("rv32ui-p-slt.bin", "rb");      check_ok(fd, 25);
    fd = $fopen("rv32ui-p-slti.bin", "rb");     check_ok(fd, 26);
    fd = $fopen("rv32ui-p-sltiu.bin", "rb");    check_ok(fd, 27);
    fd = $fopen("rv32ui-p-sltu.bin", "rb");     check_ok(fd, 28);
    fd = $fopen("rv32ui-p-sra.bin", "rb");      check_ok(fd, 29);
    fd = $fopen("rv32ui-p-srai.bin", "rb");     check_ok(fd, 30);
    fd = $fopen("rv32ui-p-srl.bin", "rb");      check_ok(fd, 31);
    fd = $fopen("rv32ui-p-srli.bin", "rb");     check_ok(fd, 32);
    fd = $fopen("rv32ui-p-sub.bin", "rb");      check_ok(fd, 33);
    fd = $fopen("rv32ui-p-sw.bin", "rb");       check_ok(fd, 34);
    fd = $fopen("rv32ui-p-xor.bin", "rb");      check_ok(fd, 35);
    fd = $fopen("rv32ui-p-xori.bin", "rb");     check_ok(fd, 36);
    fd = $fopen("rv32ui-p-fence_i.bin", "rb");  check_ok(fd, 37);
    fd = $fopen("rv32ui-p-simple.bin", "rb");   check_ok(fd, 38);
end
endtask

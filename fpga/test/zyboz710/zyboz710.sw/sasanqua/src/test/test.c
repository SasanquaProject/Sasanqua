#include "string.h"
#include "xil_printf.h"
#include "xil_cache.h"
#include "sleep.h"

#include "../utils.h"
#include "riscv-tests/rv32ui-p.h"

#define t2s(a) #a
#define testcase(ty, name) result = run_testcase(t2s(ty ## _ ## name), ty ## _ ## name ##_bin, ty ##_ ## name ## _bin_len)

int run_testcase(char *name, unsigned char *program, size_t length) {
	static int success_cnt = 0;
	static int all_cnt = 0;

	write_program((unsigned char*)0x20000000, program, length);
	reset();

	xil_printf("%s ... ", name);
	sleep(1);

	++ all_cnt;
	if (STAT == 1) {
		++ success_cnt;
		xil_printf("Success!\n");
	} else {
		xil_printf("Failed (at %d)\n", STAT >> 1);
	}

	return success_cnt * 1000 + all_cnt;
}

int test(void) {
	int result;

	testcase(rv32ui_p, add);
	testcase(rv32ui_p, addi);
	testcase(rv32ui_p, and);
	testcase(rv32ui_p, andi);
	testcase(rv32ui_p, auipc);
	testcase(rv32ui_p, beq);
	testcase(rv32ui_p, bge);
	testcase(rv32ui_p, bgeu);
	testcase(rv32ui_p, blt);
	testcase(rv32ui_p, bltu);
	testcase(rv32ui_p, bne);
	testcase(rv32ui_p, fence_i);
	testcase(rv32ui_p, jal);
	testcase(rv32ui_p, jalr);
	testcase(rv32ui_p, lb);
	testcase(rv32ui_p, lbu);
	testcase(rv32ui_p, lh);
	testcase(rv32ui_p, lhu);
	testcase(rv32ui_p, lui);
	testcase(rv32ui_p, lw);
	testcase(rv32ui_p, or);
	testcase(rv32ui_p, ori);
	testcase(rv32ui_p, sb);
	testcase(rv32ui_p, sh);
	testcase(rv32ui_p, simple);
	testcase(rv32ui_p, sll);
	testcase(rv32ui_p, slli);
	testcase(rv32ui_p, slt);
	testcase(rv32ui_p, slti);
	testcase(rv32ui_p, sltiu);
	testcase(rv32ui_p, sltu);
	testcase(rv32ui_p, sra);
	testcase(rv32ui_p, srai);
	testcase(rv32ui_p, srl);
	testcase(rv32ui_p, srli);
	testcase(rv32ui_p, sub);
	testcase(rv32ui_p, sw);
	testcase(rv32ui_p, xor);
	testcase(rv32ui_p, xori);

	xil_printf("Result : %3d /%3d\n\n", result/1000, result%1000);

	return 0;
}

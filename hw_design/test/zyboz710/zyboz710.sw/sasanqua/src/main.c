#include "string.h"
#include "xil_printf.h"
#include "xil_cache.h"
#include "sleep.h"

#include "riscv-tests/rv32ui-p.h"

#define RST		(*(volatile unsigned int*)(XPAR_SASANQUA_CONTROLLER_0_BASEADDR + 0x0000))
#define STAT	(*(volatile unsigned int*)(XPAR_SASANQUA_CONTROLLER_0_BASEADDR + 0x0004))

#define t2s(a) #a
#define test(ty, name) result = run_test(t2s(ty ## _ ## name), ty ## _ ## name ##_bin, ty ##_ ## name ## _bin_len)

void setup(unsigned char *addr, unsigned char *program, size_t length) {
	for (int idx = 0; idx < length; ++ idx) {
		*(addr++) = *(program++);
	}
}

void reset(void) {
	Xil_Out32(0xF8000008, 0x0000DF0D); // UNLOCK SCLR
	Xil_Out32(0xF8000240, 0x00000001); // ASSERT FCLK_RESET0
	Xil_Out32(0xF8000240, 0x00000000); // DE-ASSERT FCLK_RESET0
	Xil_Out32(0xF8000004, 0x0000767B); // LOCK SCLR
}

int run_test(char *name, unsigned char *program, size_t length) {
	static int success_cnt = 0;
	static int all_cnt = 0;

	setup((unsigned char*)0x20000000, program, length);
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

int main(void) {
	Xil_DCacheDisable();

	int result;

	test(rv32ui_p, add);
	test(rv32ui_p, addi);
	test(rv32ui_p, and);
	test(rv32ui_p, andi);
	test(rv32ui_p, auipc);
	test(rv32ui_p, beq);
	test(rv32ui_p, bge);
	test(rv32ui_p, bgeu);
	test(rv32ui_p, blt);
	test(rv32ui_p, bltu);
	test(rv32ui_p, bne);
	test(rv32ui_p, fence_i);
	test(rv32ui_p, jal);
	test(rv32ui_p, jalr);
	test(rv32ui_p, lb);
	test(rv32ui_p, lbu);
	test(rv32ui_p, lh);
	test(rv32ui_p, lhu);
	test(rv32ui_p, lui);
	test(rv32ui_p, lw);
	test(rv32ui_p, or);
	test(rv32ui_p, ori);
	test(rv32ui_p, sb);
	test(rv32ui_p, sh);
	test(rv32ui_p, simple);
	test(rv32ui_p, sll);
	test(rv32ui_p, slli);
	test(rv32ui_p, slt);
	test(rv32ui_p, slti);
	test(rv32ui_p, sltiu);
	test(rv32ui_p, sltu);
	test(rv32ui_p, sra);
	test(rv32ui_p, srai);
	test(rv32ui_p, srl);
	test(rv32ui_p, srli);
	test(rv32ui_p, sub);
	test(rv32ui_p, sw);
	test(rv32ui_p, xor);
	test(rv32ui_p, xori);

	xil_printf("Result : %3d /%3d\n\n", result/1000, result%1000);

	return 0;
}

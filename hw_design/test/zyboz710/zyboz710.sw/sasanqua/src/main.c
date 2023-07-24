#include "string.h"
#include "xil_printf.h"
#include "xil_cache.h"

#define RST		(*(volatile unsigned int*)(XPAR_SASANQUA_CONTROLLER_0_BASEADDR + 0x0000))
#define STAT	(*(volatile unsigned int*)(XPAR_SASANQUA_CONTROLLER_0_BASEADDR + 0x0004))

int main(void) {
	Xil_DCacheDisable();

	RST = 0;
	RST = 1;
	RST = 0;

	xil_printf("Stat : %d\n", STAT);

	return 0;
}

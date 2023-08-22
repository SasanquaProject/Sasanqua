#include "string.h"
#include "xil_printf.h"
#include "xil_cache.h"
#include "sleep.h"

#define RST		(*(volatile unsigned int*)(XPAR_SASANQUA_CONTROLLER_0_BASEADDR + 0x0000))
#define STAT	(*(volatile unsigned int*)(XPAR_SASANQUA_CONTROLLER_0_BASEADDR + 0x0004))

int main(void) {
	Xil_DCacheDisable();

	xil_printf("Running ... ");
	sleep(4);
	xil_printf("=> 0x%8x\n", STAT);

	return 0;
}

#include "string.h"
#include "sleep.h"

void reset(void) {
	Xil_Out32(0xF8000008, 0x0000DF0D); // UNLOCK SCLR
	Xil_Out32(0xF8000240, 0x00000001); // ASSERT FCLK_RESET0
	Xil_Out32(0xF8000240, 0x00000000); // DE-ASSERT FCLK_RESET0
	Xil_Out32(0xF8000004, 0x0000767B); // LOCK SCLR
}

void write_program(unsigned char *addr, unsigned char *program, size_t length) {
	for (int idx = 0; idx < length; ++ idx) {
		*(addr++) = *(program++);
	}
}

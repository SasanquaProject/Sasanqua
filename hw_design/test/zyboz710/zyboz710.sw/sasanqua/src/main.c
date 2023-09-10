#include "string.h"
#include "xil_printf.h"
#include "xil_cache.h"
#include "sleep.h"

#include "test/test.h"

int main(void) {
	Xil_DCacheDisable();

	test();

	return 0;
}

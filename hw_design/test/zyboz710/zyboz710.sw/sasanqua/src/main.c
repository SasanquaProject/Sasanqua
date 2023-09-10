#include "string.h"
#include "xil_printf.h"
#include "xil_cache.h"
#include "sleep.h"

#include "utils.h"
#include "test/test.h"
#include "orig/orig.h"

int main(void) {
	Xil_DCacheDisable();

//	test();
	orig();

	return 0;
}

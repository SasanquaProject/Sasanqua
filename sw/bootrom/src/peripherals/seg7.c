#include "seg7.h"

void seg7_write(unsigned int val) {
    SEG7_REG = val;
}

unsigned int seg7_read() {
    return SEG7_REG;
}

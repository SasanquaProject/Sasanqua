#include "clint.h"

void clint_set_timer(unsigned int duration) {
    MTIME = 0;
    MTIMECMP = duration;
}

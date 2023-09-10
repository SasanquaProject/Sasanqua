#ifndef CLINT_H
#define CLINT_H

#define MTIMECMP (*((volatile unsigned int*)0x02004000))
#define MTIME    (*((volatile unsigned int*)0x0200bff8))

void clint_set_timer(unsigned int duration);

#endif

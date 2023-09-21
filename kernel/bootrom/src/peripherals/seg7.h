#ifndef SEG_H
#define SEG_H

#define SEG7_REG (*((volatile unsigned int*)0x40020000))

void seg7_write(unsigned int val);

#endif

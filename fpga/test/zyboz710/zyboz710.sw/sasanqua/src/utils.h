#ifndef UTILS_H
#define UTILS_H

#define RST		(*(volatile unsigned int*)(XPAR_SASANQUA_CONTROLLER_0_BASEADDR + 0x0000))
#define STAT	(*(volatile unsigned int*)(XPAR_SASANQUA_CONTROLLER_0_BASEADDR + 0x0004))

void reset(void);
void write_program(unsigned char *addr, unsigned char *program, size_t length);

#endif

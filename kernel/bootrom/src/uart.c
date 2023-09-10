#include "uart.h"

void uart_reset(void) {
    CTRL = 0b00011;   // reset tx/rx fifo
}

void uart_wait() {
    while(STAT != 0b100);
}

void uart_sendc(char c) {
    uart_wait();
    TX = (unsigned char)c;
}

void uart_sendsln(char *s) {
    for (char *c = s; *c != '\0'; ++ c) {
        uart_wait();
        TX = (unsigned char)(*c);
    }
    TX = 0x0d;
    TX = 0x0a;
}

#include "utils.h"
#include "peripherals/clint.h"
#include "peripherals/uart.h"

#define SEC 1000000  // = 100Mhz / 100

void trap_handler(void) {
    clint_set_timer(1*SEC);
}

int main(void) {
    /* Setup peripherals */
    uart_reset();

    /* Boot process */
    uart_sendc('H');
    uart_sendc('e');
    uart_sendc('l');
    uart_sendc('l');
    uart_sendc('o');
    uart_sendc('!');
    uart_sendc('\r');
    uart_sendc('\n');

    while (1) { }
}

#include "clint.h"
#include "uart.h"

#define SEC 1000000  // = 100Mhz / 100

void int_allow();
void int_disallow();

void trap_handler(void) {
    uart_sendsln("Trap.");
    clint_set_timer(1*SEC);
    int_allow();
}

int main(void) {
    /* Setup peripherals */
    // UART
    uart_reset();

    // CLINT
    clint_set_timer(1*SEC);

    /* Boot process */
    uart_sendsln("Hello!");
    int_allow();
    while (1) { }
}

#include "utils.h"
#include "peripherals/clint.h"
#include "peripherals/uart.h"
#include "peripherals/spi.h"
#include "peripherals/seg7.h"

#define SEC 1000000  // = 100Mhz / 100

void trap_handler(void) {
    clint_set_timer(1*SEC);
}

int main(void) {
    /* Setup peripherals */
    // UART
    uart_init();
    uart_sendc('0');

    // SPI
    spi_init();
    uart_sendc('1');

    // spi_read();

    /* Boot process */
    uart_sendc('H');
    uart_sendc('e');
    uart_sendc('l');
    uart_sendc('l');
    uart_sendc('o');
    uart_sendc('!');
    uart_sendc('\r');
    uart_sendc('\n');

    seg7_write(0x123456);

    while (1) { }
}

#include "utils.h"
#include "peripherals/clint.h"
#include "peripherals/uart.h"
#include "peripherals/spi.h"
#include "peripherals/seg7.h"

#define SEC  500000 // 50Mhz / 100
#define MSEC 500    // 50MHz / 10,000

void trap_handler(void) {
    clint_set_timer(1*SEC);
    seg7_write(seg7_read() + 1);
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

    seg7_write(0);

    clint_set_timer(1*SEC);
    int_allow();

    while (1) { }
}

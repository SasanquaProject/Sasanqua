#include "utils.h"
#include "peripherals/clint.h"
#include "peripherals/uart.h"
#include "peripherals/spi.h"
#include "peripherals/seg7.h"
#include "peripherals/gpio.h"

#define SEC  500000 // 50Mhz / 100
#define MSEC 500    // 50MHz / 10,000

void trap_handler(void) {
    clint_set_timer(1*SEC);
    seg7_write(seg7_read() + 1);
}

void setup(void) {
    // UART
    uart_init();

    // SPI
    // spi_init();

    // GPIO (Switch x 4)
    gpio_init((INPUT<<3) | (INPUT<<2) | (INPUT<<1) | INPUT);
}

int run(void) {
    uart_sendc('B');
    uart_sendc('o');
    uart_sendc('o');
    uart_sendc('t');
    uart_sendc(':');
    uart_sendc('0' + gpio_in());
    uart_sendc('\r');
    uart_sendc('\n');

    seg7_write(0);

    clint_set_timer(1*SEC);
    int_allow();

    while (1) { }
}

int main(void) {
    setup();
    run();
}

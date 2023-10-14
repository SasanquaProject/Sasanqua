#include "gpio.h"

void gpio_init(unsigned int type) {
    GPIO_TRI = type;
}

unsigned int gpio_in() {
    return GPIO_DATA;
}

void gpio_out(unsigned int data) {
    GPIO_DATA = data;
}

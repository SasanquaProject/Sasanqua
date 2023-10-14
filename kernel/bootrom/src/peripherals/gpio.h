#ifndef GPIO_H
#define GPIO_H

#define GPIO_DATA (*((volatile unsigned int*)0x40030000))
#define GPIO_TRI  (*((volatile unsigned int*)0x40030004))

#define INPUT     0b1
#define OUTPUT    0b0

void gpio_init(unsigned int type);
unsigned int gpio_in();
void gpio_out(unsigned int data);

#endif

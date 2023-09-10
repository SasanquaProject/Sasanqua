#ifndef UART_H
#define UART_H

#define RX (*((volatile unsigned char*)0x40000000))
#define TX (*((volatile unsigned char*)0x40000004))
#define STAT (*((volatile unsigned char*)0x40000008))
#define CTRL (*((volatile unsigned char*)0x4000000C))

void uart_reset(void);
void uart_sendc(char c);
void uart_sendsln(char *s);

#endif

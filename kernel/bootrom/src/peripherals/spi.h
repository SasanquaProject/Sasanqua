#ifndef SPI_H
#define SPI_H

#define SRR     (*((volatile unsigned int*)0x40010040))
#define CR      (*((volatile unsigned int*)0x40010060))
#define SR      (*((volatile unsigned int*)0x40010064))
#define DTR     (*((volatile unsigned char*)0x40010068))
#define DRR     (*((volatile unsigned char*)0x4001006C))
#define SSR     (*((volatile unsigned int*)0x40010070))
#define WCNT    (*((volatile unsigned int*)0x40010074))
#define RCNT    (*((volatile unsigned int*)0x40010078))

void spi_command(
    unsigned char command,
    unsigned char arg1,
    unsigned char arg2,
    unsigned char arg3,
    unsigned char arg4,
    unsigned char crc7
);
volatile unsigned char spi_receive();

void spi_init();
void spi_read();

#endif

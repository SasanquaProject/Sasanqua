#include "uart.h"
#include "spi.h"

void spi_command(
    unsigned char command,
    unsigned char arg1,
    unsigned char arg2,
    unsigned char arg3,
    unsigned char arg4,
    unsigned char crc7
)
{
    // Control : Transaction disable | Chip select enable | Rx FIFO reset | Tx FIFO reset |
    //           Master mode | SPI enable
    CR = 0b0111100110;

    // Tx FIFO
    DTR = command;
    DTR = arg1;
    DTR = arg2;
    DTR = arg3;
    DTR = arg4;
    DTR = crc7;

    // Chip Select : No.0 enable
    SSR = 0b1;

    // Control : Transaction enable
    CR = 0b0010000110;

    while (RCNT != 5);

    // Chip Select : No.0 disable
    SSR = 0b0;

    // Control : Transaction disable
    CR = 0b0110000110;
}

volatile unsigned char spi_receive() {
    // Control : Transaction disable | Chip select enable | Rx FIFO reset | Tx FIFO reset |
    //           Master mode | SPI enable
    CR = 0b0111100110;

    // Tx FIFO
    DTR = 0xFF;

    // Chip Select : No.0 enable
    SSR = 0b1;

    // Control : Transaction enable
    CR = 0b0010000110;

    while (SR & 0b1 == 1);

    // Chip Select : No.0 disable
    SSR = 0b0;

    // Control : Transaction disable
    CR = 0b0110000110;

    return DRR;
}

void spi_init() {
    unsigned char recv;

    SRR = 0xa;

    // CMD0
    spi_command(0x40, 0x00, 0x00, 0x00, 0x00, 0x95);
    while (spi_receive() != 0x01);

    // CMD1
    spi_command(0x41, 0x00, 0x00, 0x00, 0x00, 0xF9);
    while (spi_receive() != 0x00);

    // CMD16 (512B)
    spi_command(0x50, 0x00, 0x00, 0x02, 0x00, 0x00);
    while (spi_receive() != 0x00);
}

void spi_read() {
    // CMD17
    spi_command(0x51, 0x00, 0x00, 0x20, 0x00, 0x00);
    while (spi_receive() != 0x00);

    while (spi_receive() != 0xFE);
    for (int cnt = 0; cnt < 512; ++ cnt) {
        unsigned char recv = spi_receive();
        uart_sendc(recv);
    }
    uart_receive();
    uart_receive();
    uart_receive();
}

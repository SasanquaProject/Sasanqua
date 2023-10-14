# UART
set_property PACKAGE_PIN W14 [get_ports UART_CTS]
set_property IOSTANDARD LVCMOS33 [get_ports UART_CTS]

set_property PACKAGE_PIN Y14 [get_ports UART_TXD]
set_property IOSTANDARD LVCMOS33 [get_ports UART_TXD]

set_property PACKAGE_PIN T12 [get_ports UART_RXD]
set_property IOSTANDARD LVCMOS33 [get_ports UART_RXD]

set_property PACKAGE_PIN U12 [get_ports UART_RTS]
set_property IOSTANDARD LVCMOS33 [get_ports UART_RTS]

# SPI
set_property PACKAGE_PIN T14 [get_ports {SPI_CSN[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SPI_CSN[0]}]

set_property PACKAGE_PIN T15 [get_ports SPI_MOSI]
set_property IOSTANDARD LVCMOS33 [get_ports SPI_MOSI]

set_property PACKAGE_PIN P14 [get_ports SPI_MISO]
set_property IOSTANDARD LVCMOS33 [get_ports SPI_MISO]

set_property PACKAGE_PIN R14 [get_ports SPI_SCLK]
set_property IOSTANDARD LVCMOS33 [get_ports SPI_SCLK]

# 7seg LED
set_property PACKAGE_PIN V12 [get_ports COM_SER]
set_property IOSTANDARD LVCMOS33 [get_ports COM_SER]

set_property PACKAGE_PIN W16 [get_ports COM_RCLK]
set_property IOSTANDARD LVCMOS33 [get_ports COM_RCLK]

set_property PACKAGE_PIN V13 [get_ports COM_SRCLK]
set_property IOSTANDARD LVCMOS33 [get_ports COM_SRCLK]

set_property PACKAGE_PIN J15 [get_ports SEG_SER]
set_property IOSTANDARD LVCMOS33 [get_ports SEG_SER]

set_property PACKAGE_PIN H15 [get_ports SEG_RCLK]
set_property IOSTANDARD LVCMOS33 [get_ports SEG_RCLK]

set_property PACKAGE_PIN T17 [get_ports SEG_SRCLK]
set_property IOSTANDARD LVCMOS33 [get_ports SEG_SRCLK]

# LED
set_property PACKAGE_PIN D18 [get_ports {LED[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[3]}]

set_property PACKAGE_PIN G14 [get_ports {LED[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[2]}]

set_property PACKAGE_PIN M15 [get_ports {LED[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[1]}]

set_property PACKAGE_PIN M14 [get_ports {LED[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[0]}]

# Switch
set_property PACKAGE_PIN T16 [get_ports {SWITCH[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SWITCH[3]}]

set_property PACKAGE_PIN W13 [get_ports {SWITCH[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SWITCH[2]}]

set_property PACKAGE_PIN P15 [get_ports {SWITCH[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SWITCH[1]}]

set_property PACKAGE_PIN G15 [get_ports {SWITCH[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SWITCH[0]}]

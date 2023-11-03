SHELL := /bin/bash

IMAGE := riscv/devenv

AS_OPTS := -march=rv32i_zicsr -mabi=ilp32
GCC_OPTS := -O1 -march=rv32i_zicsr -mabi=ilp32
LD_OPTS := -T link.ld -b elf32-littleriscv

bootrom.mem:
	docker run --rm -it -v $(shell pwd):/src -w /src $(IMAGE) /bin/bash -c "make bootrom.mem.in"
	sudo chown -R 1000:1000 *

bootrom.mem.in: boot.S src/*.c src/peripherals/*.c
	riscv64-unknown-elf-as $(AS_OPTS) -o boot.o boot.S
	riscv64-unknown-elf-gcc $(GCC_OPTS) -c -o main.o src/main.c
	riscv64-unknown-elf-gcc $(GCC_OPTS) -c -o clint.o src/peripherals/clint.c
	riscv64-unknown-elf-gcc $(GCC_OPTS) -c -o uart.o src/peripherals/uart.c
	riscv64-unknown-elf-gcc $(GCC_OPTS) -c -o spi.o src/peripherals/spi.c
	riscv64-unknown-elf-gcc $(GCC_OPTS) -c -o seg7.o src/peripherals/seg7.c
	riscv64-unknown-elf-gcc $(GCC_OPTS) -c -o gpio.o src/peripherals/gpio.c
	riscv64-unknown-elf-ld $(LD_OPTS) -o bootrom *.o
	riscv64-unknown-elf-objcopy -O binary bootrom bootrom.bin
	riscv64-unknown-elf-objdump -d bootrom &> bootrom.dump
	od -An -tx4 -w4 -v bootrom.bin > bootrom.mem

clean:
	rm -f bootrom bootrom.dump bootrom.mem bootrom.bin *.o

.PHONY: bootrom.mem bootrom.mem.in clean

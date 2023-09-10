SHELL := /bin/bash

IMAGE := riscv/devenv

devenv:
	docker run --rm -it -v $(shell pwd):/src -w /src $(IMAGE) /bin/bash -c "make bootrom.mem"
	sudo chown -R 1000:1000 *

bootrom.mem: boot.S src/*.c
	riscv64-unknown-elf-as -march=rv32i_zicsr -mabi=ilp32 -o boot.o boot.S
	riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -c -o main.o src/main.c
	riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -c -o clint.o src/clint.c
	riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -c -o uart.o src/uart.c
	riscv64-unknown-elf-ld -T link.ld -b elf32-littleriscv -o bootrom *.o
	riscv64-unknown-elf-objcopy -O binary bootrom bootrom.bin
	riscv64-unknown-elf-objdump -d bootrom &> bootrom.dump
	od -An -tx4 -w4 -v bootrom.bin > bootrom.mem

clean:
	rm -f bootrom bootrom.dump bootrom.mem bootrom.o bootrom.bin

.PHONY: clean

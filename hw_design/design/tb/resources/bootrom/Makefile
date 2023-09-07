SHELL := /bin/bash

IMAGE := riscv/devenv

bootrom.mem: boot.S main.c
	riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -c -o main.o main.c
	riscv64-unknown-elf-as -march=rv32i_zicsr -mabi=ilp32 -o boot.o boot.S
	riscv64-unknown-elf-ld -T link.ld -b elf32-littleriscv -o bootrom boot.o main.o
	riscv64-unknown-elf-objdump -d bootrom > bootrom.dump
	riscv64-unknown-elf-objcopy -O binary bootrom bootrom.bin
	od -An -tx4 -w4 -v bootrom.bin > bootrom.mem

clean:
	rm bootrom bootrom.dump bootrom.mem bootrom.o bootrom.bin

.PHONY: clean

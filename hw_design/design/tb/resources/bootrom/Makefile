SHELL := /bin/bash

IMAGE := riscv/devenv

bootrom.mem: bootrom.S
	riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 -o bootrom.o bootrom.S
	riscv64-unknown-elf-ld -T link.ld -b elf32-littleriscv -o bootrom bootrom.o
	riscv64-unknown-elf-objcopy -O binary bootrom bootrom.bin
	od -An -tx4 -w4 -v bootrom.bin > bootrom.mem

clean:
	rm bootrom bootrom.dump bootrom.mem bootrom.o bootrom.bin

.PHONY: clean

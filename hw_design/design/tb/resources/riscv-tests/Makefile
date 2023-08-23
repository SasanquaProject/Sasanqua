SHELL := /bin/bash

IMAGE := riscv/devenv

TARGET_DIR := ./target
BIN_DIR := ./bin
ELF_FILES := $(shell find ${TARGET_DIR}/share/riscv-tests/isa/rv32*i-p*)

bin:
	make elf
	mkdir -p $(BIN_DIR)
	for f in $(ELF_FILES); do\
		if [[ ! $$f =~ "dump" ]]; then\
			FILE_NAME="$${f##*/}";\
			echo $$FILE_NAME;\
			riscv64-unknown-elf-objcopy -O binary $$f $(BIN_DIR)/$$FILE_NAME.bin;\
		fi;\
	done

elf:
	cp link.ld riscv-tests/env/p
	cp link.ld riscv-tests/env/v
	cp link.ld /opt/riscv/riscv-tests/env/p
	cp link.ld /opt/riscv/riscv-tests/env/v
	cd riscv-tests && autoconf
	cd riscv-tests && ./configure --prefix=/src/riscv-tests/$(TARGET_DIR)
	cd riscv-tests && make
	cd riscv-tests && make install

.PHONY: bin elf

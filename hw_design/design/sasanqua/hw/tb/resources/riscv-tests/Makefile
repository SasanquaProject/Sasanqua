SHELL := /bin/bash

IMAGE := riscv/devenv

TARGET_DIR := ./target
OUT_DIR := ./out
ELF_FILES := $(shell find ${TARGET_DIR}/share/riscv-tests/isa/rv32*i*)

bin:
	mkdir -p $(OUT_DIR)/bin
	mkdir -p $(OUT_DIR)/cheader
	for f in $(ELF_FILES); do\
		if [[ ! $$f =~ "dump" ]]; then\
			FILE_NAME="$${f##*/}";\
			echo $$FILE_NAME;\
			riscv64-unknown-elf-objcopy -O binary $$f $(OUT_DIR)/bin/$$FILE_NAME.bin;\
			cd $(OUT_DIR)/bin && xxd -i $$FILE_NAME.bin > ../cheader/$$FILE_NAME.h && cd ../../;\
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

SHELL := /bin/bash

IMAGE := riscv/devenv

ELF_FILES := $(shell find ./elf/rv32*i-p*)
SAVE_DIR := ./bin

bin:
	mkdir -p $(SAVE_DIR)
	for f in $(ELF_FILES); do\
		if [[ ! $$f =~ "dump" ]]; then\
			FILE_NAME="$${f##*/}";\
			echo $$FILE_NAME;\
			riscv64-unknown-elf-objcopy -O binary $$f $(SAVE_DIR)/$$FILE_NAME.bin;\
		fi;\
	done

.PHONY: bin

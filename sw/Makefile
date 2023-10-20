APP := helloworld

app:
	cargo objdump --bin $(APP) -- -dSC > $(APP).dump
	cargo objcopy --bin $(APP) -- -O binary $(APP).bin
	od -An -tx4 -w4 -v $(APP).bin > $(APP).mem
	rm -f $(APP).bin

clean:
	rm -rf *.dump *.mem

.PHONY: kernel.mem clean

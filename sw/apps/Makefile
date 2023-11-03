TARGET := helloworld

app:
	# cargo objdump --bin $(TARGET) -- -dSC > $(TARGET).dump
	cargo objcopy --bin $(TARGET) -- -O binary $(TARGET).bin
	od -An -tx4 -w4 -v $(TARGET).bin > $(TARGET).mem
	rm -f $(TARGET).bin

clean:
	rm -rf *.dump *.mem

.PHONY: app clean

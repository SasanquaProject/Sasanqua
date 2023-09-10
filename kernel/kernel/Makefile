bootrom.mem:
	cargo objdump -- -dSC > bootrom.dump
	cargo objcopy -- -O binary bootrom.bin
	od -An -tx4 -w4 -v bootrom.bin > bootrom.mem

clean:
	rm -rf bootrom.bin bootrom.dump bootrom.mem

.PHONY: bootrom.mem clean

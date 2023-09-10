kernel.mem:
	cargo objdump -- -dSC > kernel.dump
	cargo objcopy -- -O binary kernel.bin
	od -An -tx4 -w4 -v kernel.bin > kernel.mem

clean:
	rm -rf kernel.bin kernel.dump kernel.mem

.PHONY: kernel.mem clean

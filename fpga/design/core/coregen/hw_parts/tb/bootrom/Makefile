IMAGE := riscv/devenv

bootrom:
	docker run --rm -it -v $(shell pwd):/src -w /src $(IMAGE) /bin/bash -c "make -f Makefile.in bootrom.mem"
	chown $(shell id -u):$(shell id -u) -R *

clean:
	rm -f bootrom bootrom.bin bootrom.dump bootrom.mem

.PHONY: bootrom clean

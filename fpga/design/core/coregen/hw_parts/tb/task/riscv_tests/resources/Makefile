IMAGE := riscv/devenv

riscv-tests:
	docker run --rm -it -v $(shell pwd):/src -w /src $(IMAGE) /bin/bash -c "make -f Makefile.in bin"

.PHONY: riscv-tests

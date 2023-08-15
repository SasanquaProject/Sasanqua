IMAGE := riscv/devenv

all: riscv-tests

riscv-tests:
	docker run --rm -it -v $(shell pwd):/src -w /src $(IMAGE) /bin/bash -c "make -C riscv-tests"

devenv:
	docker run --rm -it -v $(shell pwd):/src -w /src $(IMAGE) /bin/bash

.PHONY: riscv-tests

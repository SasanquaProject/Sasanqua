COREGEN_CBIN := ./target/release/coregen_cui
COREGEN_GBIN := ./target/release/coregen_gui

build:
	cargo build --release

new:
	$(COREGEN_CBIN) new -o core.toml

gen:
	$(COREGEN_CBIN) gen core.toml -o core_ip

clean:
	rm -rf core.toml core_ip

.PHONY: build clean new gen clean

COPGEN_CBIN := ./target/release/copgen_cui
COPGEN_GBIN := ./target/release/copgen_gui

build:
	cargo build --release

new:
	$(COPGEN_CBIN) new -o cop.toml

gen:
	$(COPGEN_CBIN) gen cop.toml -o cop_ip

clean:
	rm -rf cop.toml cop_ip

.PHONY: build clean new gen clean

# CopGen

## コマンド

```
// Build (once)
$ make build

// Generate a Core-IP
$ make new
$ make gen

// CUI
$ cargo run --bin copgen_cui

// GUI
$ cargo run --bin copgen_gui
```

## クレート

### bin

- [src/cui](./src/cui/README.md)
- [src/gui](./src/gui/README.md)

### lib

- copgen
- [impl/std](./impl/std/README.md)
- [impl/verilog](./impl/verilog/README.md)
- [impl/chisel](./impl/chisel/README.md)

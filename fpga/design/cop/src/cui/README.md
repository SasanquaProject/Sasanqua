# CopGen - CUI

## Example

```
$ cargo run
> new example 0.1.0
Ok

> list
RISC-V Standard extensions
  - rv32i_mini
Others
  - void

> add rv32i_mini
OK

> status
Status: ok (examle, 0.1.0)
Cop-Impls:
  - Cop#0 = Rv32iMin

> generate Any
Ok

> exit

$ ls
example_ip
```

.global start

start:
    addi t0, x0, 0
    lui t0, 0x20000
    jalr x0, t0, 0

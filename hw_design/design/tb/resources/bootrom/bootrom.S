.global start

start:
    j setup

trap_vector:
    nop

setup:
    la t0, trap_vector
    csrw mtvec, t0
    lui t0, 0x1000C
    addi t0, t0, -8
    lw t1, 0(t0)
    addi t1, t1, 10
    lui t0, 0x10004
    sw t1, 0(t0)

loop:
    j loop

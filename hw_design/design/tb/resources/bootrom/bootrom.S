.global start

start:
    j setup

trap_vector:
    nop

setup:
    la t0, trap_vector
    csrw mtvec, t0
    lui t0, 0x0200C
    addi t0, t0, -8
    lw t1, 0(t0)
    addi t1, t1, 10
    lui t0, 0x02004
    sw t1, 0(t0)
    csrwi mstatus, 8

loop:
    j loop

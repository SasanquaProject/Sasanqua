.global _start
.global int_allow, int_disallow

_start:
    j setup

trap_vector:
    csrr t2, mepc

    call trap_handler

    jalr x0, 0(t2)

setup:
    la t0, trap_vector
    csrw mtvec, t0

    lui sp, 0x40000
    addi sp, sp, -4

    j main

int_allow:
    csrwi mstatus, 8
    ret

int_disallow:
    csrwi mstatus, 0
    ret

OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY {
    RAM(rx) : ORIGIN = 0x20000000, LENGTH = 512M
}

SECTIONS {
    .isr_vector : {
        . = ALIGN(4);
        KEEP(*(.isr_vector))
        . = ALIGN(4);
    } > ROM

    .text : {
        . = ALIGN(4);
        *(.text .text.*);
        . = ALIGN(4);
    } > ROM

    .rodata : {
        . = ALIGN(4);
        *(.rodata .rodata.*);
        . = ALIGN(4);
    } > ROM

    .data : {
        . = ALIGN(4);
        *(.sdata .sdata.* .data .data.*);
        . = ALIGN(4);
    } > ROM

    .bss : {
        *(.sbss .sbss.* .bss .bss.*);
        . = ALIGN(4);
    } > ROM
}

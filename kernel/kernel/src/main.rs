#![no_std]
#![no_main]

use core::arch::global_asm;
use core::panic::PanicInfo;

#[allow(unused_imports)]
use riscv::asm;

global_asm!(r#"
.section .isr_vector, "ax"
    j _start
.section .text, "ax"
_start:
    j start_rust
"#);

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

#[no_mangle]
pub unsafe extern "C" fn start_rust() {
    extern "Rust" {
        fn setup();
        fn run() -> !;
    }

    setup();
    run()
}

#[no_mangle]
pub extern "C" fn setup() {

}

#[no_mangle]
pub extern "C" fn run() {
    loop {}
}

#![no_std]

pub mod __export {
    pub use core;
    pub use riscv;
}

#[macro_export]
macro_rules! riscv_main {
    ($($body:tt)*) => {
        use $crate::__export::core::arch::global_asm;
        use $crate::__export::core::panic::PanicInfo;

        #[allow(unused_imports)]
        use $crate::__export::riscv::asm;

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
                fn run() -> !;
            }
            run()
        }

        #[no_mangle]
        pub extern "C" fn run() {
            $( $body )*
        }
    };
}

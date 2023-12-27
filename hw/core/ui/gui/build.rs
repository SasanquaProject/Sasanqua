fn main() {
    slint_build::compile("slint/Main.slint").unwrap();

    println!("cargo:rerun-if-changed=ui/*.slint");
    println!("cargo:rerun-if-changed=build.rs");
}

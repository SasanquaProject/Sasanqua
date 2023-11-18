fn main() {
    slint_build::compile("design/Main.slint").unwrap();

    println!("cargo:rerun-if-changed=design/**/*.slint");
    println!("cargo:rerun-if-changed=design/*.slint");
    println!("cargo:rerun-if-changed=build.rs");
}

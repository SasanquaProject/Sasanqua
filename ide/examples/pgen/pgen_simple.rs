use pgen::gen;
use pgen::vendor::Xilinx;

fn main() {
    gen::<Xilinx>("pgen_simple", "0.1.0").unwrap();
}

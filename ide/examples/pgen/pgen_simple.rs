use pgen::gen;
use pgen::vendor::Xilinx;
use pgen::sasanqua::{Sasanqua, BusInterface};

fn main() {
    let sasanqua = Sasanqua::new(BusInterface::AXI);
    gen::<Xilinx>("pgen_simple", "0.1.0", sasanqua).unwrap();
}

use pgen::gen;
use pgen::vendor::Xilinx;
use pgen::sasanqua::Sasanqua;
use pgen::sasanqua::bus::AXI4;

fn main() -> anyhow::Result<()> {
    let sasanqua = Sasanqua::new(AXI4);
    gen("pgen_simple", "0.1.0", Xilinx, sasanqua)
}

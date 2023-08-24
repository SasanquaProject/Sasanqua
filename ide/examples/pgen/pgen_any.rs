use pgen::gen;
use pgen::sasanqua::bus::AXI4;
use pgen::sasanqua::Sasanqua;
use pgen::vendor::Any;

fn main() -> anyhow::Result<()> {
    let sasanqua = Sasanqua::new(AXI4);
    gen("pgen_any", "0.1.0", Any, sasanqua)
}

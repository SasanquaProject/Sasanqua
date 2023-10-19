use vfs::{MemoryFS, PhysicalFS};

use ipgen::vendor::Xilinx;
use ipgen::ip::IPInfo;
use ipgen::gen;

fn main() -> anyhow::Result<()> {
    let dst_dir = "./example_ip";

    std::fs::create_dir(dst_dir)?;
    let fs = PhysicalFS::new(dst_dir).into();

    let ipinfo = IPInfo::new_mini("Example", "0.1.0");
    gen::<Xilinx>(fs, ipinfo, MemoryFS::new().into())?;

    Ok(())
}

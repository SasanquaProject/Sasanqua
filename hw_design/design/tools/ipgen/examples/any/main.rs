use vfs::PhysicalFS;

use ipgen::IPInfo;
use ipgen::vendor::Any;

fn main() -> anyhow::Result<()> {
    let dst_dir = "./example_ip";

    std::fs::create_dir(dst_dir)?;
    let mut fs = PhysicalFS::new(dst_dir).into();

    let ipinfo = IPInfo::new("Example", "0.1.0");
    ipinfo.gen::<Any>(&mut fs)
}

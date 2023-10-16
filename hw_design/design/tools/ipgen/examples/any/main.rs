use vfs::PhysicalFS;

use ipgen::vendor::Any;
use ipgen::IPInfo;

fn main() -> anyhow::Result<()> {
    let dst_dir = "./example_ip";

    std::fs::create_dir(dst_dir)?;
    let mut fs = PhysicalFS::new(dst_dir).into();

    let ipinfo = IPInfo::new("Example", "0.1.0", vec![]);
    ipinfo.gen::<Any>(&mut fs)
}

use vfs::PhysicalFS;

use ipgen::IPInfo;
use ipgen::vendor::Vendor;

pub fn gen<V>(name: impl Into<String>, version: impl Into<String>) -> anyhow::Result<()>
where
    V: Vendor,
{
    let name = name.into();
    let version = version.into();

    let mut fs = PhysicalFS::new(name.clone()).into();
    IPInfo::new(name, version).gen::<V>(&mut fs)?;

    Ok(())
}

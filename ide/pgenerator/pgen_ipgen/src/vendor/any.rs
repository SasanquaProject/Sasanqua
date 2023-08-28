use vfs::VfsPath;

use hwgen::sasanqua::bus::BusInterface;
use hwgen::SasanquaT;

use crate::utils::vfs::merge_vfs;
use crate::vendor::Vendor;
use crate::IPInfo;

pub struct Any;

impl<S, B> Vendor<S, B> for Any
where
    S: SasanquaT<B>,
    B: BusInterface,
{
    fn gen(ipinfo: &IPInfo<S, B>, root: &mut VfsPath) -> anyhow::Result<()> {
        root.join("src")?.create_dir()?;
        merge_vfs(root, "src", ipinfo.sasanqua.gen()?)?;

        root.join("README.txt")?
            .create_file()?
            .write_all(format!("Name: {}\nVersion: {}", ipinfo.name, ipinfo.version).as_bytes())?;

        Ok(())
    }
}

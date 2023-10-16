use vfs::VfsPath;

use crate::utils::vfs::merge_vfs;
use crate::vendor::Vendor;
use crate::IPInfo;

pub struct Any;

impl Vendor for Any {
    fn gen(ipinfo: IPInfo, root: &mut VfsPath) -> anyhow::Result<()> {
        root.join("src")?.create_dir()?;
        merge_vfs(root, "src", ipinfo.src_fs)?;

        root.join("README.txt")?
            .create_file()?
            .write_all(format!("Name: {}\nVersion: {}", ipinfo.name, ipinfo.version).as_bytes())?;

        Ok(())
    }
}

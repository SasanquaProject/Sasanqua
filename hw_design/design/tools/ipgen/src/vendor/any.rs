use vfs::VfsPath;

use crate::utils::merge_vfs;
use crate::vendor::Vendor;
use crate::IPInfo;

pub struct Any;

impl Vendor for Any {
    fn gen(vfs: &mut VfsPath, ipinfo: IPInfo, src: VfsPath) -> anyhow::Result<()> {
        vfs.join("src")?.create_dir()?;
        merge_vfs(vfs, "src", src)?;

        vfs.join("README.txt")?
            .create_file()?
            .write_all(format!("Name: {}\nVersion: {}", ipinfo.name, ipinfo.version).as_bytes())?;

        Ok(())
    }
}

#[cfg(test)]
mod test {
    use thiserror::Error;
    use vfs::{MemoryFS, VfsPath};

    use super::Any;
    use crate::{gen, IPInfo};

    #[test]
    fn check_req_files() {
        let ipinfo = IPInfo::default();
        let vfs = gen::<Any>(MemoryFS::new().into(), ipinfo, MemoryFS::new().into()).unwrap();

        assert!(open_file(&vfs, "README.txt").is_ok());
    }

    fn open_file(root: &VfsPath, path: &str) -> anyhow::Result<VfsPath> {
        #[derive(Error, Debug)]
        #[error("A specified file is not found.")]
        struct FileNotFound;

        let f = root.join(path).unwrap();
        let exists = f.exists()?;
        if !exists {
            return Err(FileNotFound.into());
        }

        Ok(f)
    }
}

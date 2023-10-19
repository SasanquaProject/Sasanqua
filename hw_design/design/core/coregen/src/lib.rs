mod factory;
pub mod sasanqua;

use std::fs::create_dir;

use vfs::{MemoryFS, PhysicalFS, VfsPath};

use ipgen::vendor::Vendor;
use ipgen::IPInfo;

use factory::{Factory, HwMakable};
use sasanqua::Sasanqua;

pub fn gen_physfs<V, S>(sasanqua: &Sasanqua, dir: S) -> anyhow::Result<VfsPath>
where
    V: Vendor,
    S: Into<String>,
{
    let dir = dir.into();

    create_dir(&dir)?;
    let fs = PhysicalFS::new(dir).into();
    gen0::<V>(fs, sasanqua)
}

pub fn gen_memfs<V>(sasanqua: &Sasanqua) -> anyhow::Result<VfsPath>
where
    V: Vendor,
{
    let fs = MemoryFS::new().into();
    gen0::<V>(fs, sasanqua)
}

fn gen0<V: Vendor>(mut vfs: VfsPath, sasanqua: &Sasanqua) -> anyhow::Result<VfsPath> {
    let mut src_fs = MemoryFS::new().into();
    Factory::make(sasanqua, &mut src_fs)?;

    IPInfo::new("sasanqua_core", "0.1.0", src_fs).gen::<V>(&mut vfs)?;

    Ok(vfs)
}

#[cfg(test)]
mod test {
    use thiserror::Error;
    use vfs::VfsPath;

    use ipgen::vendor::Any;

    use crate::gen_memfs;
    use crate::sasanqua::bus::AXI4;
    use crate::sasanqua::Sasanqua;

    #[test]
    fn check_req_files() {
        let sasanqua = Sasanqua::new(AXI4);
        let hw_vfs = gen_memfs::<Any>(&sasanqua).unwrap();

        assert!(open_file(&hw_vfs, "src/sasanqua.v").is_ok());
        assert!(open_file(&hw_vfs, "src/core/core.v").is_ok());
        assert!(open_file(&hw_vfs, "src/mem/axi/mem.v").is_ok());
        assert!(open_file(&hw_vfs, "src/mem/utils/ram/ram_dualport.v").is_ok());
        assert!(open_file(&hw_vfs, "src/peripherals/clint.v").is_ok());
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

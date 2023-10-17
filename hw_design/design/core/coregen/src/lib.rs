mod factory;
pub mod sasanqua;

use std::fs::create_dir;

use vfs::{PhysicalFS, MemoryFS, VfsPath};

use factory::{Factory, HwMakable};
use sasanqua::Sasanqua;

pub fn gen_physfs<S: Into<String>>(sasanqua: &Sasanqua, dir: S) -> anyhow::Result<VfsPath> {
    let dir = dir.into();

    create_dir(&dir)?;
    let fs = PhysicalFS::new(dir).into();
    gen0(fs, sasanqua)
}

pub fn gen_memfs(sasanqua: &Sasanqua) -> anyhow::Result<VfsPath> {
    let fs = MemoryFS::new().into();
    gen0(fs, sasanqua)
}

fn gen0(mut vfs: VfsPath, sasanqua: &Sasanqua) -> anyhow::Result<VfsPath> {
    Factory::make(sasanqua, &mut vfs)?;
    Ok(vfs)
}

#[cfg(test)]
mod test {
    use thiserror::Error;
    use vfs::VfsPath;

    use crate::gen_memfs;
    use crate::sasanqua::Sasanqua;
    use crate::sasanqua::bus::AXI4;

    #[test]
    fn check_req_files() {
        let sasanqua = Sasanqua::new(AXI4);
        let hw_vfs = gen_memfs(&sasanqua).unwrap();

        assert!(open_file(&hw_vfs, "sasanqua.v").is_ok());
        assert!(open_file(&hw_vfs, "core/core.v").is_ok());
        assert!(open_file(&hw_vfs, "mem/axi/mem.v").is_ok());
        assert!(open_file(&hw_vfs, "mem/utils/ram/ram_dualport.v").is_ok());
        assert!(open_file(&hw_vfs, "peripherals/clint.v").is_ok());
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

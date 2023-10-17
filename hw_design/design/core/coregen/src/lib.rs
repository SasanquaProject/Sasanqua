mod factory;
pub mod sasanqua;

use vfs::{MemoryFS, VfsPath};

use factory::{Factory, HwMakable};
use sasanqua::Sasanqua;

pub fn gen(sasanqua: &Sasanqua) -> anyhow::Result<VfsPath> {
    let mut root = MemoryFS::new().into();
    Factory::make(sasanqua, &mut root)?;
    Ok(root)
}

#[cfg(test)]
mod test {
    use thiserror::Error;
    use vfs::VfsPath;

    use crate::gen;
    use crate::sasanqua::Sasanqua;
    use crate::sasanqua::bus::AXI4;

    #[test]
    fn check_req_files() {
        let sasanqua = Sasanqua::new(AXI4);
        let hw_vfs = gen(&sasanqua).unwrap();

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

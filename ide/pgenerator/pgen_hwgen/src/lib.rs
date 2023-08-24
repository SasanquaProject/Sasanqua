pub mod sasanqua;
mod factory;
mod resources;

use vfs::{VfsPath, MemoryFS};

use sasanqua::Sasanqua;
use sasanqua::bus::{BusInterface, AXI4};

pub trait SasanquaT<B>
where
    Self: std::fmt::Debug,
    B: BusInterface,
{
    fn gen(&self) -> anyhow::Result<VfsPath>;
}

impl SasanquaT<AXI4> for Sasanqua<AXI4> {
    fn gen(&self) -> anyhow::Result<VfsPath> {
        let mut root = MemoryFS::new().into();
        factory::gen(self, &mut root)?;

        Ok(root)
    }
}

#[cfg(test)]
mod test {
    use thiserror::Error;
    use vfs::VfsPath;

    use super::SasanquaT;
    use super::sasanqua::Sasanqua;
    use super::sasanqua::bus::AXI4;

    #[test]
    fn check_req_files() {
        let sasanqua = Sasanqua::new(AXI4);
        let hw_vfs = sasanqua.gen().unwrap();

        assert!(open_file(&hw_vfs, "sasanqua.v").is_ok());
        assert!(open_file(&hw_vfs, "core/core.v").is_ok());
        assert!(open_file(&hw_vfs, "core/pipeline/check.v").is_ok());
        assert!(open_file(&hw_vfs, "core/pipeline/cushion.v").is_ok());
        assert!(open_file(&hw_vfs, "core/pipeline/decode.v").is_ok());
        assert!(open_file(&hw_vfs, "core/pipeline/fetch.v").is_ok());
        assert!(open_file(&hw_vfs, "core/pipeline/mread.v").is_ok());
        assert!(open_file(&hw_vfs, "core/pipeline/schedule_1st.v").is_ok());
        assert!(open_file(&hw_vfs, "core/pipeline/exec/std_rv32i_s.v").is_ok());
        assert!(open_file(&hw_vfs, "core/pipeline/register/std_csr.v").is_ok());
        assert!(open_file(&hw_vfs, "core/pipeline/register/std_rv32i.v").is_ok());
        assert!(open_file(&hw_vfs, "mmu/axi/cache.v").is_ok());
        assert!(open_file(&hw_vfs, "mmu/axi/interconnect.v").is_ok());
        assert!(open_file(&hw_vfs, "mmu/axi/mmu.v").is_ok());
        assert!(open_file(&hw_vfs, "mmu/axi/translate.v").is_ok());
        assert!(open_file(&hw_vfs, "mmu/utils/ram/ram_dualport.v").is_ok());
        assert!(open_file(&hw_vfs, "mmu/utils/rom/rom_dualport.v").is_ok());
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

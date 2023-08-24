mod resources;

use vfs::{VfsPath, MemoryFS};

pub struct Sasanqua {
    pub bus_if: BusInterface,
}

pub enum BusInterface {
    AXI,
}

impl Sasanqua {
    pub fn new(bus_if: BusInterface) -> Sasanqua {
        Sasanqua { bus_if }
    }

    pub fn gen(&self) -> anyhow::Result<VfsPath> {
        let fs = MemoryFS::new();
        let root = fs.into();

        Ok(root)
    }
}

#[cfg(test)]
mod test {
    use vfs::VfsPath;

    use super::{Sasanqua, BusInterface};

    #[test]
    fn check_req_files() {
        let sasanqua = Sasanqua::new(BusInterface::AXI);
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
        assert!(open_file(&hw_vfs, "mmu/mmu.v").is_ok());
        assert!(open_file(&hw_vfs, "mmu/axi/cache.v").is_ok());
        assert!(open_file(&hw_vfs, "mmu/axi/interconnect.v").is_ok());
        assert!(open_file(&hw_vfs, "mmu/axi/mmu.v").is_ok());
        assert!(open_file(&hw_vfs, "mmu/axi/translate.v").is_ok());
        assert!(open_file(&hw_vfs, "mmu/utils/ram/ram_dualport.v").is_ok());
        assert!(open_file(&hw_vfs, "mmu/utils/rom/rom_dualport.v").is_ok());
    }

    fn open_file(root: &VfsPath, path: &str) -> anyhow::Result<VfsPath> {
        let f = root.join(path).unwrap();
        assert!(f.exists()?);
        Ok(f)
    }
}

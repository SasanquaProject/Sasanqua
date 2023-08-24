use vfs::VfsPath;

use crate::Sasanqua;
use crate::resources::*;
use super::HwFactory;

pub struct MMUFactory;

impl HwFactory for MMUFactory {
    fn gen(_: &Sasanqua, root: &mut VfsPath) -> anyhow::Result<()> {
        // mmu
        root.join("mmu")?.create_dir()?;

        // mmu/axi
        root.join("mmu/axi")?.create_dir()?;

        root.join("mmu/axi/cache.v")?
            .create_file()?
            .write_all(MMU_AXI_CACHE_V.as_bytes())?;

        root.join("mmu/axi/interconnect.v")?
            .create_file()?
            .write_all(MMU_AXI_INTERCONNECT_V.as_bytes())?;

        root.join("mmu/axi/mmu.v")?
            .create_file()?
            .write_all(MMU_AXI_MMU_V.as_bytes())?;
        root.join("mmu/axi/translate.v")?
            .create_file()?
            .write_all(MMU_AXI_TRANSLATE_V.as_bytes())?;

        // mmu/utils
        root.join("mmu/utils")?.create_dir()?;

        // mmu/utils/ram
        root.join("mmu/utils/ram")?.create_dir()?;

        root.join("mmu/utils/ram/ram_dualport.v")?
            .create_file()?
            .write_all(MMU_UTILS_RAM_DUALPORT_V.as_bytes())?;

        // mmu/utils/rom
        root.join("mmu/utils/rom")?.create_dir()?;

        root.join("mmu/utils/rom/rom_dualport.v")?
            .create_file()?
            .write_all(MMU_UTILS_ROM_DUALPORT_V.as_bytes())?;

        Ok(())
    }
}

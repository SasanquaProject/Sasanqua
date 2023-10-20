use vfs::VfsPath;

use super::HwMakable;
use crate::Sasanqua;

pub struct MemFactory;

impl HwMakable for MemFactory {
    fn make(_: &Sasanqua, root: &mut VfsPath) -> anyhow::Result<()> {
        // mem
        root.join("mem")?.create_dir()?;

        // mem/axi
        root.join("mem/axi")?.create_dir()?;

        root.join("mem/axi/cache.v")?
            .create_file()?
            .write_all(include_bytes!("../../hw_parts/src/mem/axi/cache.v"))?;

        root.join("mem/axi/interconnect.v")?
            .create_file()?
            .write_all(include_bytes!("../../hw_parts/src/mem/axi/interconnect.v"))?;

        root.join("mem/axi/mem.v")?
            .create_file()?
            .write_all(include_bytes!("../../hw_parts/src/mem/axi/mem.v"))?;

        root.join("mem/axi/translate.v")?
            .create_file()?
            .write_all(include_bytes!("../../hw_parts/src/mem/axi/translate.v"))?;

        // mem/utils
        root.join("mem/utils")?.create_dir()?;

        // mem/utils/ram
        root.join("mem/utils/ram")?.create_dir()?;

        root.join("mem/utils/ram/ram_dualport.v")?
            .create_file()?
            .write_all(include_bytes!(
                "../../hw_parts/src/mem/utils/ram/ram_dualport.v"
            ))?;

        // mem/utils/rom
        root.join("mem/utils/rom")?.create_dir()?;

        root.join("mem/utils/rom/rom_dualport.v")?
            .create_file()?
            .write_all(include_bytes!(
                "../../hw_parts/src/mem/utils/rom/rom_dualport.v"
            ))?;

        Ok(())
    }
}

use vfs::VfsPath;

use super::HwFactory;
use crate::sasanqua::bus::AXI4;
use crate::Sasanqua;

pub struct PeripheralsFactory;

impl HwFactory<AXI4> for PeripheralsFactory {
    fn make(_: &Sasanqua<AXI4>, root: &mut VfsPath) -> anyhow::Result<()> {
        // peripherals
        root.join("peripherals")?.create_dir()?;

        root.join("peripherals/clint.v")?
            .create_file()?
            .write_all(include_bytes!("../../hw_parts/src/peripherals/clint.v"))?;

        root.join("peripherals/plic.v")?
            .create_file()?
            .write_all(include_bytes!("../../hw_parts/src/peripherals/plic.v"))?;

        Ok(())
    }
}

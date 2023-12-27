use vfs::VfsPath;

use super::HwMakable;
use crate::Sasanqua;

pub struct PeripheralsFactory;

impl HwMakable for PeripheralsFactory {
    fn make(_: &Sasanqua, root: &mut VfsPath) -> anyhow::Result<()> {
        // peripherals
        root.join("peripherals")?.create_dir()?;

        root.join("peripherals/clint.v")?
            .create_file()?
            .write_all(include_bytes!("../../hw_parts/peripherals/clint.v"))?;

        root.join("peripherals/plic.v")?
            .create_file()?
            .write_all(include_bytes!("../../hw_parts/peripherals/plic.v"))?;

        Ok(())
    }
}

use vfs::VfsPath;

use super::HwFactory;
use crate::sasanqua::bus::AXI4;
use crate::Sasanqua;

pub struct SasanquaFactory;

impl HwFactory<AXI4> for SasanquaFactory {
    fn make(_: &Sasanqua<AXI4>, root: &mut VfsPath) -> anyhow::Result<()> {
        root.join("sasanqua.v")?
            .create_file()?
            .write_all(include_bytes!("../../hw_parts/src/sasanqua.v"))?;

        Ok(())
    }
}

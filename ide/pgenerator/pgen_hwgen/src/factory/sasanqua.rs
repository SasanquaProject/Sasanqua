use vfs::VfsPath;

use super::HwFactory;
use crate::resources::*;
use crate::sasanqua::bus::AXI4;
use crate::sasanqua::Sasanqua;

pub struct SasanquaFactory;

impl HwFactory<AXI4> for SasanquaFactory {
    fn gen(_: &Sasanqua<AXI4>, root: &mut VfsPath) -> anyhow::Result<()> {
        root.join("sasanqua.v")?
            .create_file()?
            .write_all(SASANQUA_V.as_bytes())?;

        Ok(())
    }
}

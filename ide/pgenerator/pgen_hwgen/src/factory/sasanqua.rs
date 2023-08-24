use vfs::VfsPath;

use crate::Sasanqua;
use crate::resources::*;
use super::HwFactory;

pub struct SasanquaFactory;

impl HwFactory for SasanquaFactory {
    fn gen(_: &Sasanqua, root: &mut VfsPath) -> anyhow::Result<()> {
        root.join("sasanqua.v")?
            .create_file()?
            .write_all(SASANQUA_V.as_bytes())?;

        Ok(())
    }
}

use vfs::VfsPath;

use super::HwFactory;
use crate::resources::*;
use crate::Sasanqua;

pub struct SasanquaFactory;

impl HwFactory for SasanquaFactory {
    fn gen(_: &Sasanqua, root: &mut VfsPath) -> anyhow::Result<()> {
        root.join("sasanqua.v")?
            .create_file()?
            .write_all(SASANQUA_V.as_bytes())?;

        Ok(())
    }
}

use vfs::VfsPath;

use super::HwMakable;
use crate::Sasanqua;

pub struct SasanquaFactory;

impl HwMakable for SasanquaFactory {
    fn make(_: &Sasanqua, root: &mut VfsPath) -> anyhow::Result<()> {
        root.join("sasanqua.v")?
            .create_file()?
            .write_all(include_bytes!("../../hw_parts/src/sasanqua.v"))?;

        Ok(())
    }
}

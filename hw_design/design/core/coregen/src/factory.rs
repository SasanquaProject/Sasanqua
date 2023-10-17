mod core;
mod mem;
mod sasanqua;
mod peripherals;

use vfs::VfsPath;

use self::core::CoreFactory;
use self::mem::MemFactory;
use self::peripherals::PeripheralsFactory;
use self::sasanqua::SasanquaFactory;
use crate::Sasanqua;

pub trait HwMakable {
    fn make(sasanqua: &Sasanqua, root: &mut VfsPath) -> anyhow::Result<()>;
}

pub struct Factory;

impl HwMakable for Factory {
    fn make(sasanqua: &Sasanqua, root: &mut VfsPath) -> anyhow::Result<()> {
        SasanquaFactory::make(sasanqua, root)?;
        CoreFactory::make(sasanqua, root)?;
        MemFactory::make(sasanqua, root)?;
        PeripheralsFactory::make(sasanqua, root)?;

        Ok(())
    }
}

mod core;
mod mem;
mod sasanqua;

use vfs::VfsPath;

use self::core::CoreFactory;
use self::mem::MemFactory;
use self::sasanqua::SasanquaFactory;
use crate::sasanqua::bus::BusInterface;
use crate::Sasanqua;

pub trait HwFactory<B>
where
    B: BusInterface,
{
    fn make(sasanqua: &Sasanqua<B>, root: &mut VfsPath) -> anyhow::Result<()>;
}

pub fn make<B>(sasanqua: &Sasanqua<B>, root: &mut VfsPath) -> anyhow::Result<()>
where
    B: BusInterface,
    SasanquaFactory: HwFactory<B>,
    CoreFactory: HwFactory<B>,
    MemFactory: HwFactory<B>,
{
    SasanquaFactory::make(sasanqua, root)?;
    CoreFactory::make(sasanqua, root)?;
    MemFactory::make(sasanqua, root)?;

    Ok(())
}

mod core;
mod mmu;
mod sasanqua;

use vfs::VfsPath;

use self::core::CoreFactory;
use self::mmu::MMUFactory;
use self::sasanqua::SasanquaFactory;
use crate::sasanqua::bus::BusInterface;
use crate::sasanqua::Sasanqua;

pub trait HwFactory<B>
where
    B: BusInterface,
{
    fn gen(sasanqua: &Sasanqua<B>, root: &mut VfsPath) -> anyhow::Result<()>;
}

pub fn gen<B>(sasanqua: &Sasanqua<B>, root: &mut VfsPath) -> anyhow::Result<()>
where
    B: BusInterface,
    SasanquaFactory: HwFactory<B>,
    CoreFactory: HwFactory<B>,
    MMUFactory: HwFactory<B>,
{
    SasanquaFactory::gen(sasanqua, root)?;
    CoreFactory::gen(sasanqua, root)?;
    MMUFactory::gen(sasanqua, root)?;

    Ok(())
}

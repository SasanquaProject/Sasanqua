mod core;
mod mmu;
mod sasanqua;

use vfs::VfsPath;

use self::core::CoreFactory;
use self::mmu::MMUFactory;
use self::sasanqua::SasanquaFactory;
use crate::Sasanqua;

trait HwFactory {
    fn gen(sasanqua: &Sasanqua, root: &mut VfsPath) -> anyhow::Result<()>;
}

pub fn gen_verilog_files(sasanqua: &Sasanqua, root: &mut VfsPath) -> anyhow::Result<()> {
    <SasanquaFactory as HwFactory>::gen(sasanqua, root)?;
    <CoreFactory as HwFactory>::gen(sasanqua, root)?;
    <MMUFactory as HwFactory>::gen(sasanqua, root)?;

    Ok(())
}

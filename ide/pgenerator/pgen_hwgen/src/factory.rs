mod sasanqua;
mod core;
mod mmu;

use vfs::VfsPath;

use crate::Sasanqua;
use self::sasanqua::SasanquaFactory;
use self::core::CoreFactory;
use self::mmu::MMUFactory;

trait HwFactory {
    fn gen(sasanqua: &Sasanqua, root: &mut VfsPath) -> anyhow::Result<()>;
}

pub fn gen_verilog_files(sasanqua: &Sasanqua, root: &mut VfsPath) -> anyhow::Result<()> {
    <SasanquaFactory as HwFactory>::gen(sasanqua, root)?;
    <CoreFactory as HwFactory>::gen(sasanqua, root)?;
    <MMUFactory as HwFactory>::gen(sasanqua, root)?;

    Ok(())
}

mod xilinx;

use vfs::VfsPath;

use hwgen::SasanquaT;
use hwgen::sasanqua::bus::BusInterface;

use crate::IPInfo;
pub use xilinx::Xilinx;

pub trait Vendor<S, B>
where
    S: SasanquaT<B>,
    B: BusInterface,
{
    fn gen(info: &IPInfo<S, B>, root: &mut VfsPath) -> anyhow::Result<()>;
}

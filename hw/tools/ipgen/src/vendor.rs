mod any;
mod xilinx;

use vfs::VfsPath;

use crate::ip::IPInfo;
pub use any::Any;
pub use xilinx::Xilinx;

pub trait Vendor {
    fn gen(vfs: &mut VfsPath, info: IPInfo, src: VfsPath) -> anyhow::Result<()>;
}

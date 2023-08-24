mod xilinx;

use vfs::VfsPath;

use crate::IPInfo;

pub use xilinx::Xilinx;

pub trait Vendor {
    fn gen(info: &IPInfo, root: &mut VfsPath) -> anyhow::Result<()>;
}

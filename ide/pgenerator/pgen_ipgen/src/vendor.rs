mod xilinx;

use vfs::FileSystem;

use crate::IPInfo;

pub use xilinx::Xilinx;

pub trait Vendor {
    fn gen(info: &IPInfo, fs: &mut impl FileSystem) -> anyhow::Result<()>;
}

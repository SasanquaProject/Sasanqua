mod xilinx;

use crate::IPInfo;

pub use xilinx::Xilinx;

pub trait Vendor {
    fn gen(info: &IPInfo) -> anyhow::Result<()>;
}

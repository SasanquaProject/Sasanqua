use crate::IPInfo;
use crate::vendor::Vendor;

pub struct Xilinx;

impl Vendor for Xilinx {
    fn gen(_: &IPInfo) -> anyhow::Result<()> {
        // TODO: component.xml
        // TODO: xgui/**.tcl
        // TODO: bd/*.tcl
        Ok(())
    }
}

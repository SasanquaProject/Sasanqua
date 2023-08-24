use vfs::VfsPath;

use crate::IPInfo;
use crate::vendor::Vendor;

pub struct Xilinx;

impl Vendor for Xilinx {
    fn gen(_: &IPInfo, _: &mut VfsPath) -> anyhow::Result<()> {
        // TODO: component.xml
        // TODO: xgui/**.tcl
        // TODO: bd/*.tcl
        Ok(())
    }
}

#[cfg(test)]
mod test {
    use vfs::{VfsPath, MemoryFS};

    use crate::IPInfo;
    use super::Xilinx;

    #[test]
    fn check_req_files() {
        let mut root = MemoryFS::new().into();
        IPInfo::new("test", "0.1.0").gen::<Xilinx>(&mut root).unwrap();

        assert!(open_file(&root, "component.xml").is_ok());
        assert!(open_file(&root, "xgui/xgui.tcl").is_ok());
        assert!(open_file(&root, "bd/bd.tcl").is_ok());
    }

    fn open_file(root: &VfsPath, path: &str) -> anyhow::Result<VfsPath> {
        let f = root.join(path).unwrap();
        assert!(f.exists()?);
        Ok(f)
    }
}

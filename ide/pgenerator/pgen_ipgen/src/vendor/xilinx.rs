mod bd;
mod xgui;

use vfs::VfsPath;

use crate::vendor::Vendor;
use crate::IPInfo;

pub struct Xilinx;

impl Vendor for Xilinx {
    fn gen(_: &IPInfo, root: &mut VfsPath) -> anyhow::Result<()> {
        // TODO: component.xml

        root.join("bd")?.create_dir()?;
        root.join("bd/bd.tcl")?
            .create_file()?
            .write_all(bd::BD_TCL)?;

        root.join("xgui")?.create_dir()?;
        root.join("xgui/xgui.tcl")?
            .create_file()?
            .write_all(xgui::XGUI_TCL)?;

        Ok(())
    }
}

#[cfg(test)]
mod test {
    use vfs::{MemoryFS, VfsPath};

    use super::Xilinx;
    use crate::IPInfo;

    #[test]
    fn check_req_files() {
        let mut root = MemoryFS::new().into();
        IPInfo::new("test", "0.1.0")
            .gen::<Xilinx>(&mut root)
            .unwrap();

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

mod bd;
mod xgui;

use vfs::VfsPath;

// use crate::utils::vfs::merge_vfs;
use crate::utils::ip_xact::gen_ip_xact_xml;
use crate::vendor::Vendor;
use crate::IPInfo;

pub struct Xilinx;

impl Vendor for Xilinx {
    fn gen(ipinfo: &IPInfo, root: &mut VfsPath) -> anyhow::Result<()> {
        root.join("src")?.create_dir()?;
        // merge_vfs(root, "src", ipinfo.sasanqua.gen()?)?;

        root.join("bd")?.create_dir()?;
        root.join("bd/bd.tcl")?
            .create_file()?
            .write_all(bd::BD_TCL)?;

        root.join("xgui")?.create_dir()?;
        root.join("xgui/xgui.tcl")?
            .create_file()?
            .write_all(xgui::XGUI_TCL)?;

        root.join("component.xml")?
            .create_file()?
            .write_all(gen_ip_xact_xml(ipinfo).as_bytes())?;

        Ok(())
    }
}

#[cfg(test)]
mod test {
    use thiserror::Error;
    use vfs::{MemoryFS, VfsPath};

    use super::Xilinx;
    use crate::IPInfo;

    #[test]
    fn check_req_files() {
        let mut root = MemoryFS::new().into();
        IPInfo::new("test", "0.1.0", MemoryFS::new().into())
            .gen::<Xilinx>(&mut root)
            .unwrap();

        assert!(open_file(&root, "component.xml").is_ok());
        assert!(open_file(&root, "xgui/xgui.tcl").is_ok());
        assert!(open_file(&root, "bd/bd.tcl").is_ok());
        // assert!(open_file(&root, "src/sasanqua.v").is_ok());
    }

    fn open_file(root: &VfsPath, path: &str) -> anyhow::Result<VfsPath> {
        #[derive(Error, Debug)]
        #[error("A specified file is not found.")]
        struct FileNotFound;

        let f = root.join(path).unwrap();
        let exists = f.exists()?;
        if !exists {
            return Err(FileNotFound.into());
        }

        Ok(f)
    }
}

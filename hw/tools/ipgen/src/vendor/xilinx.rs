mod bd;
mod xgui;

use vfs::VfsPath;

use crate::ip::gen_ip_xact_xml;
use crate::utils::merge_vfs;
use crate::vendor::Vendor;
use crate::IPInfo;

pub struct Xilinx;

impl Vendor for Xilinx {
    fn gen(vfs: &mut VfsPath, ipinfo: IPInfo, src: VfsPath) -> anyhow::Result<()> {
        vfs.join("component.xml")?
            .create_file()?
            .write_all(gen_ip_xact_xml(&ipinfo).as_bytes())?;

        vfs.join("bd")?.create_dir()?;
        vfs.join("bd/bd.tcl")?
            .create_file()?
            .write_all(bd::BD_TCL)?;

        vfs.join("xgui")?.create_dir()?;
        vfs.join("xgui/xgui.tcl")?
            .create_file()?
            .write_all(xgui::XGUI_TCL)?;

        vfs.join("src")?.create_dir()?;
        merge_vfs(vfs, "src", src)?;

        Ok(())
    }
}

#[cfg(test)]
mod test {
    use thiserror::Error;
    use vfs::{MemoryFS, VfsPath};

    use super::Xilinx;
    use crate::{gen, IPInfo};

    #[test]
    fn check_req_files() {
        let ipinfo = IPInfo::default();
        let vfs = gen::<Xilinx>(MemoryFS::new().into(), ipinfo, MemoryFS::new().into()).unwrap();

        assert!(open_file(&vfs, "component.xml").is_ok());
        assert!(open_file(&vfs, "xgui/xgui.tcl").is_ok());
        assert!(open_file(&vfs, "bd/bd.tcl").is_ok());
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

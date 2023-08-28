mod bd;
mod component;
mod xgui;

use vfs::VfsPath;

use hwgen::sasanqua::bus::BusInterface;
use hwgen::SasanquaT;

use crate::utils::vfs::merge_vfs;
use crate::vendor::Vendor;
use crate::IPInfo;

pub struct Xilinx;

impl<S, B> Vendor<S, B> for Xilinx
where
    S: SasanquaT<B>,
    B: BusInterface,
{
    fn gen(ipinfo: &IPInfo<S, B>, root: &mut VfsPath) -> anyhow::Result<()> {
        root.join("src")?.create_dir()?;
        merge_vfs(root, "src", ipinfo.sasanqua.gen()?)?;

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
            .write_all(component::component_xml().as_bytes())?;

        Ok(())
    }
}

#[cfg(test)]
mod test {
    use thiserror::Error;
    use vfs::{MemoryFS, VfsPath};

    use hwgen::sasanqua::bus::AXI4;
    use hwgen::sasanqua::Sasanqua;

    use super::Xilinx;
    use crate::IPInfo;

    #[test]
    fn check_req_files() {
        let sasanqua = Sasanqua::new(AXI4);

        let mut root = MemoryFS::new().into();
        IPInfo::new("test", "0.1.0", sasanqua)
            .gen::<Xilinx>(&mut root)
            .unwrap();

        assert!(open_file(&root, "component.xml").is_ok());
        assert!(open_file(&root, "xgui/xgui.tcl").is_ok());
        assert!(open_file(&root, "bd/bd.tcl").is_ok());
        assert!(open_file(&root, "src/sasanqua.v").is_ok());
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

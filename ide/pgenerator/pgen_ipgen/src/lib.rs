pub mod prelude;
pub mod vendor;
mod utils;

use vfs::VfsPath;

use vendor::Vendor;

use hwgen::Sasanqua;

#[derive(Debug)]
pub struct IPInfo {
    pub name: String,
    pub version: String,
    pub sasanqua: Sasanqua,
}

impl IPInfo {
    pub fn new<S>(name: S, version: S, sasanqua: Sasanqua) -> IPInfo
    where
        S: Into<String>,
    {
        IPInfo {
            name: name.into(),
            version: version.into(),
            sasanqua,
        }
    }

    pub fn gen<V: Vendor>(&self, root: &mut VfsPath) -> anyhow::Result<()> {
        V::gen(self, root)
    }
}

#[cfg(test)]
mod test {
    use vfs::MemoryFS;

    use hwgen::{Sasanqua, BusInterface};

    use crate::vendor::Xilinx;
    use crate::IPInfo;

    #[test]
    fn ipgen_xilinx() {
        let sasanqua = Sasanqua::new(BusInterface::AXI);

        let mut fs = MemoryFS::new().into();
        let res = IPInfo::new("Sasanqua", "0.1.0", sasanqua)
            .gen::<Xilinx>(&mut fs)
            .is_ok();
        assert!(res);
    }
}

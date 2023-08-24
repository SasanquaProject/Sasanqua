pub mod prelude;
pub mod vendor;

use vfs::VfsPath;

use vendor::Vendor;

#[derive(Debug)]
pub struct IPInfo {
    pub name: String,
    pub version: String,
}

impl IPInfo {
    pub fn new<S>(name: S, version: S) -> IPInfo
    where
        S: Into<String>,
    {
        IPInfo {
            name: name.into(),
            version: version.into(),
        }
    }

    pub fn gen<V: Vendor>(&self, root: &mut VfsPath) -> anyhow::Result<()> {
        V::gen(self, root)
    }
}

#[cfg(test)]
mod test {
    use vfs::MemoryFS;

    use crate::IPInfo;
    use crate::vendor::Xilinx;

    #[test]
    fn ipgen_xilinx() {
        let mut fs = MemoryFS::new().into();
        let res = IPInfo::new("Sasanqua", "0.1.0")
            .gen::<Xilinx>(&mut fs)
            .is_ok();
        assert!(res);
    }
}

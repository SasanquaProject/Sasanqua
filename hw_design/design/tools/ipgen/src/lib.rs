mod utils;
pub mod vendor;

use vfs::VfsPath;

use vendor::Vendor;

#[derive(Debug)]
pub struct IPInfo<'a> {
    pub name: String,
    pub version: String,
    pub files: Vec<(&'a str, &'a str)>, // name, body
}

impl<'a> IPInfo<'a> {
    pub fn new(
        name: impl Into<String>,
        version: impl Into<String>,
        files: Vec<(&'a str, &'a str)>,
    ) -> IPInfo<'a> {
        IPInfo {
            name: name.into(),
            version: version.into(),
            files,
        }
    }

    pub fn gen<V: Vendor>(&self, root: &mut VfsPath) -> anyhow::Result<()> {
        V::gen(self, root)
    }
}

#[cfg(test)]
mod test {
    use vfs::MemoryFS;

    use crate::vendor::Xilinx;
    use crate::IPInfo;

    #[test]
    fn ipgen_xilinx() {
        let mut fs = MemoryFS::new().into();
        let res = IPInfo::new("Sasanqua", "0.1.0", vec![])
            .gen::<Xilinx>(&mut fs)
            .is_ok();
        assert!(res);
    }
}

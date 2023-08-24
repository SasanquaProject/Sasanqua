pub mod vendor;

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

    pub fn gen<V: Vendor>(&self) -> anyhow::Result<()> {
        V::gen(self)
    }
}

#[cfg(test)]
mod test {
    use crate::IPInfo;
    use crate::vendor::Xilinx;

    #[test]
    fn ipgen_test() {
        let ipinfo = IPInfo::new("Sasanqua", "0.1.0");
        let res = ipinfo.gen::<Xilinx>();
        assert!(res.is_ok());
    }
}

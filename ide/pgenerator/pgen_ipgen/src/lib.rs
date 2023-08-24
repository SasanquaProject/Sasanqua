pub mod prelude;
mod utils;
pub mod vendor;

use std::marker::PhantomData;

use vfs::VfsPath;

use vendor::Vendor;

use hwgen::sasanqua::bus::BusInterface;
use hwgen::SasanquaT;

#[derive(Debug)]
pub struct IPInfo<S, B>
where
    S: SasanquaT<B>,
    B: BusInterface,
{
    pub name: String,
    pub version: String,
    pub sasanqua: Box<dyn SasanquaT<B>>,
    sasanqua_t: PhantomData<S>,
}

impl<S, B> IPInfo<S, B>
where
    S: SasanquaT<B> + 'static,
    B: BusInterface,
{
    pub fn new(name: impl Into<String>, version: impl Into<String>, sasanqua: S) -> IPInfo<S, B> {
        IPInfo {
            name: name.into(),
            version: version.into(),
            sasanqua: Box::new(sasanqua),
            sasanqua_t: PhantomData,
        }
    }

    pub fn gen<V: Vendor<S, B>>(&self, root: &mut VfsPath) -> anyhow::Result<()> {
        V::gen(self, root)
    }
}

#[cfg(test)]
mod test {
    use vfs::MemoryFS;

    use hwgen::sasanqua::bus::AXI4;
    use hwgen::sasanqua::Sasanqua;

    use crate::vendor::Xilinx;
    use crate::IPInfo;

    #[test]
    fn ipgen_xilinx() {
        let sasanqua = Sasanqua::new(AXI4);

        let mut fs = MemoryFS::new().into();
        let res = IPInfo::new("Sasanqua", "0.1.0", sasanqua)
            .gen::<Xilinx>(&mut fs)
            .is_ok();
        assert!(res);
    }
}

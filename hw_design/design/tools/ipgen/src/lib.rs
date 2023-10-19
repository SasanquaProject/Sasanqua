mod utils;
pub mod ip;
pub mod vendor;

use vfs::VfsPath;

use vendor::Vendor;
use ip::IPInfo;

pub fn gen<V: Vendor>(vfs: VfsPath, ipinfo: IPInfo, src: VfsPath) -> anyhow::Result<VfsPath> {
    let mut vfs = vfs;
    V::gen(&mut vfs, ipinfo, src)?;
    Ok(vfs)
}

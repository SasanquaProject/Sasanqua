pub mod ip;
mod utils;
pub mod vendor;

use vfs::VfsPath;

use ip::IPInfo;
use vendor::Vendor;

pub fn gen<V: Vendor>(vfs: VfsPath, ipinfo: IPInfo, src: VfsPath) -> anyhow::Result<VfsPath> {
    let mut vfs = vfs;
    V::gen(&mut vfs, ipinfo, src)?;
    Ok(vfs)
}

use std::env;
use std::fs;
use std::path::PathBuf;

use vfs::PhysicalFS;

use ipgen::vendor::Vendor;
use ipgen::IPInfo;
use hwgen::SasanquaT;
use hwgen::sasanqua::bus::BusInterface;

#[allow(unused_variables)]
pub fn gen<V, S, B>(name: impl Into<String>, version: impl Into<String>, vendor: V, sasanqua: S) -> anyhow::Result<()>
where
    V: Vendor<S, B> + 'static,
    S: SasanquaT<B> + 'static,
    B: BusInterface + 'static,
{
    let name = name.into();
    let version = version.into();

    let out_dir = setup_env(name.clone())?;
    let mut root = PhysicalFS::new(out_dir).into();
    IPInfo::new(name, version, sasanqua).gen::<V>(&mut root)?;

    Ok(())
}

fn setup_env(name: String) -> anyhow::Result<PathBuf> {
    let current_dir = env::current_dir().unwrap();
    let out_dir = current_dir.join(name);
    fs::create_dir(&out_dir)?;
    Ok(out_dir)
}

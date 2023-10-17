pub mod pkg;
pub mod profile;
mod utils;

use vfs::{MemoryFS, VfsPath};

use ipgen::vendor::Vendor;
use ipgen::IPInfo;

use pkg::CopPkg;

pub fn gen_memfs<V: Vendor>(cop_pkg: CopPkg) -> anyhow::Result<VfsPath> {
    let fs = MemoryFS::new().into();
    gen0::<V>(fs, cop_pkg)
}

fn gen0<V: Vendor>(mut vfs: VfsPath, cop_pkg: CopPkg) -> anyhow::Result<VfsPath> {
    let cop_impls_v = profile::gen_impl_vs(&cop_pkg.profiles)?;
    let cop_impls_v = cop_impls_v
        .into_iter()
        .enumerate()
        .map(|(idx, s)| (format!("cop_impl_{}.v", idx), s))
        .collect::<Vec<(String, String)>>();

    let cop_v = cop_pkg.gen()?;
    let cop_v = vec![("cop.v".to_string(), cop_v)];

    let src_fs: VfsPath = MemoryFS::new().into();
    vec![cop_impls_v, cop_v]
        .into_iter()
        .flatten()
        .for_each(|(fname, body)| {
            src_fs
                .join(fname)
                .unwrap()
                .create_file()
                .unwrap()
                .write_all(body.as_bytes())
                .unwrap();
        });

    IPInfo::new(cop_pkg.name, cop_pkg.version, src_fs).gen::<V>(&mut vfs)?;

    Ok(vfs)
}

#[cfg(test)]
mod tests {
    use vfs::VfsPath;

    use ipgen::vendor::Any;

    use crate::gen_memfs;
    use crate::pkg::CopPkg;
    use crate::profile::{CopImpl, CopImplTemplate, CopProfile, OpCode};

    #[derive(Debug)]
    pub struct TestCop;

    impl CopProfile for TestCop {
        fn opcodes(&self) -> Vec<(&'static str, OpCode)> {
            vec![
                ("INST0", OpCode::new(0b0000001, 0b000, 0b0000000)),
                ("INST1", OpCode::new(0b0000011, 0b000, 0b0000000)),
                ("INST2", OpCode::new(0b0000111, 0b000, 0b0000000)),
            ]
        }

        fn body(&self) -> CopImpl {
            CopImplTemplate::from(&TestCop)
                .set_ready("Ready")
                .set_exec("Exec")
        }
    }

    #[test]
    fn pkggen() {
        let cop_pkg = CopPkg::new("Test", "0.1.0")
            .add_cop(TestCop)
            .add_cop(TestCop);
        let memfs = gen_memfs::<Any>(cop_pkg).unwrap();

        assert!(open_file(&memfs, "src/cop.v").is_ok());
        assert!(open_file(&memfs, "src/cop_impl_0.v").is_ok());
        assert!(open_file(&memfs, "src/cop_impl_1.v").is_ok());
    }

    fn open_file(root: &VfsPath, path: &str) -> anyhow::Result<VfsPath> {
        #[derive(thiserror::Error, Debug)]
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

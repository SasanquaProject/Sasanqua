pub mod pkg;
pub mod profile;
mod utils;

use pkg::CopPkg;

pub fn gen(cop_pkg: CopPkg) -> anyhow::Result<()> {
    let cop_impls_v = profile::gen_impl_vs(&cop_pkg.profiles)?;
    let cop_impls_v = cop_impls_v
        .into_iter()
        .enumerate()
        .map(|(idx, s)| (format!("cop_impl_{}.v", idx), s))
        .collect::<Vec<(String, String)>>();

    let cop_v = cop_pkg.gen()?;
    let cop_v = vec![("cop.v".to_string(), cop_v)];

    let _dep_files = vec![cop_impls_v, cop_v]
        .into_iter()
        .flatten()
        .collect::<Vec<(String, String)>>();

    Ok(())
}

#[cfg(test)]
mod tests {
    use crate::gen;
    use crate::pkg::CopPkg;
    use crate::profile::{CopImpl, CopImplTemplate, CopProfile, OpCode};

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
        let cop_pkg = CopPkg::default().add_cop(TestCop);
        gen(cop_pkg).unwrap();
    }
}

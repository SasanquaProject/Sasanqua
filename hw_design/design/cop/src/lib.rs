mod check;
mod gen;
pub mod inst;
pub mod cop_impl;

use cop_impl::CopImpl;
use inst::OpCode;

#[derive(Default)]
pub struct CopPkg {
    profiles: Vec<Box<dyn CopProfile>>,
}

impl CopPkg {
    pub fn add_cop<C>(mut self, cop_profile: C) -> Self
    where
        C: CopProfile + 'static,
    {
        self.profiles.push(Box::new(cop_profile));
        self
    }

    pub fn gen(self) -> anyhow::Result<String> {
        check::check_pkg(&self)?;
        gen::gen_pkg(self)
    }
}

pub trait CopProfile {
    fn name(&self) -> String;
    fn opcodes(&self) -> Vec<(&'static str, OpCode)>;
    fn body(&self) -> CopImpl;
}

#[cfg(test)]
mod tests {
    use crate::cop_impl::{CopImpl, CopImplTemplate};
    use crate::inst::OpCode;
    use crate::{CopPkg, CopProfile};

    pub struct TestCop;

    impl CopProfile for TestCop {
        fn name(&self) -> String {
            "test".to_string()
        }

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
        CopPkg::default().add_cop(TestCop).gen().unwrap();
    }
}

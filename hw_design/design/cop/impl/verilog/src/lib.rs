use copgen::profile::{CopProfile, CopImpl, CopImplTemplate, OpCode};

#[derive(Debug)]
pub struct Void;

impl CopProfile for Void {
    fn opcodes(&self) -> Vec<(&'static str, OpCode)> {
        vec![]
    }

    fn body(&self) -> CopImpl {
        CopImplTemplate::from(&Void)
            .set_ready("")
            .set_exec(include_str!("../hw/src/void/exec.v"))
    }
}

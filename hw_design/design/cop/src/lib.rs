pub struct CopPkg {
    profiles: Vec<Box<dyn CopProfile>>,
}

impl CopPkg {
    pub fn new() -> Self {
        CopPkg { profiles: vec![] }
    }

    pub fn add_cop<C>(mut self, cop_profile: C) -> Self
    where
        C: CopProfile + 'static,
    {
        self.profiles.push(Box::new(cop_profile));
        self
    }
}

pub trait CopProfile {
    fn name(&self) -> String;
    fn opcodes(&self) -> Vec<OpCode>;
}

pub struct OpCode {
    pub opcode: u16,
    pub funct3: u8,
    pub funct7: u8,
}

impl OpCode {
    pub fn new(opcode: u16, funct3: u8, funct7: u8) -> Self {
        OpCode {
            opcode,
            funct3,
            funct7,
        }
    }
}

#[cfg(test)]
mod tests {
    use crate::{CopPkg, CopProfile, OpCode};

    pub struct TestCop;

    impl CopProfile for TestCop {
        fn name(&self) -> String {
            "test".to_string()
        }

        fn opcodes(&self) -> Vec<OpCode> {
            vec![
                OpCode::new(0b0000001, 0b000, 0b0000000),
                OpCode::new(0b0000011, 0b000, 0b0000000),
                OpCode::new(0b0000111, 0b000, 0b0000000),
            ]
        }
    }

    #[test]
    fn simple() {
        let _cop_pkg = CopPkg::new().add_cop(TestCop);
    }
}
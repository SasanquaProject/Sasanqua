use std::fmt::Display;

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

impl Display for OpCode {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let opcode = format!("{:b}", self.opcode);
        let funct3 = format!("{:b}", self.funct3);
        let funct7 = format!("{:b}", self.funct7);
        write!(f, "17'b{:0>10}_{:0>3}_{:0>7}", opcode, funct3, funct7)
    }
}

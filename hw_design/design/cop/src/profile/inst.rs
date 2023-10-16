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

use cop_ip::profile::{CopProfile, CopImpl, CopImplTemplate, OpCode};

pub struct Rv32iMini;

impl CopProfile for Rv32iMini {
    fn opcodes(&self) -> Vec<(&'static str, cop_ip::profile::OpCode)> {
        vec![
            ("INST_ADD", OpCode::new(0b0110011, 0b000, 0b0000000)),
            ("INST_ADDI", OpCode::new(0b0010011, 0b000, 0b0000000)),
            ("INST_SUB", OpCode::new(0b0110011, 0b000, 0b0100000)),
            ("INST_AND", OpCode::new(0b0110011, 0b111, 0b0000000)),
            ("INST_ANDI", OpCode::new(0b0010011, 0b111, 0b0000000)),
            ("INST_OR", OpCode::new(0b0110011, 0b110, 0b0000000)),
            ("INST_ORI", OpCode::new(0b0010011, 0b110, 0b0000000)),
            ("INST_XOR", OpCode::new(0b0110011, 0b100, 0b0000000)),
            ("INST_XORI", OpCode::new(0b0010011, 0b100, 0b0000000)),
            ("INST_SLL", OpCode::new(0b0110011, 0b001, 0b0000000)),
            ("INST_SLLI", OpCode::new(0b0010011, 0b001, 0b0000000)),
            ("INST_SRA", OpCode::new(0b0110011, 0b101, 0b0100000)),
            ("INST_SRAI", OpCode::new(0b0010011, 0b101, 0b0100000)),
            ("INST_SRL", OpCode::new(0b0110011, 0b101, 0b0000000)),
            ("INST_SRLI", OpCode::new(0b0010011, 0b101, 0b0000000)),
            ("INST_LUI", OpCode::new(0b0110111, 0b000, 0b0000000)),
            ("INST_AUIPC", OpCode::new(0b0010111, 0b000, 0b0000000)),
            ("INST_SLT", OpCode::new(0b0110011, 0b010, 0b0000000)),
            ("INST_SLTU", OpCode::new(0b0110011, 0b011, 0b0000000)),
            ("INST_SLTI", OpCode::new(0b0010011, 0b010, 0b0000000)),
            ("INST_SLTIU", OpCode::new(0b0010011, 0b011, 0b0000000)),
        ]
    }

    fn body(&self) -> CopImpl {
        CopImplTemplate::from(&Void)
            .set_ready("")
            .set_exec(include_str!("../hw/src/rv32i_mini/exec.v"))
    }
}

pub struct Void;

impl CopProfile for Void {
    fn opcodes(&self) -> Vec<(&'static str, cop_ip::profile::OpCode)> {
        vec![]
    }

    fn body(&self) -> CopImpl {
        CopImplTemplate::from(&Void)
            .set_ready("")
            .set_exec(include_str!("../hw/src/void/exec.v"))
    }
}

use ansi_term::Style;

use copgen::pkg::CopPkg;

use super::Executable;

pub struct List;

impl Executable for List {
    fn exec(&self, context: Option<CopPkg>, _: Vec<String>) -> anyhow::Result<Option<CopPkg>> {
        println!("{}", Style::new().bold().paint("RISC-V Standard extensions"));
        println!("  - rv32i_mini");
        println!("{}", Style::new().bold().paint("Others"));
        println!("  - void");

        Ok(context)
    }
}

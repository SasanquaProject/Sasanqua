use ansi_term::Style;

use super::Executable;

pub struct List;

impl Executable for List {
    fn exec(&self, _: Vec<String>) -> anyhow::Result<()> {
        println!("{}", Style::new().bold().paint("RISC-V Standard extensions"));
        println!("  - rv32i_mini");
        println!("{}", Style::new().bold().paint("Others"));
        println!("  - void");

        Ok(())
    }
}

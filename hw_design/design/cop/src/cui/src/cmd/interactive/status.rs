use ansi_term::Color;

use super::Executable;

use copgen::pkg::CopPkg;

pub struct Status;

impl Executable for Status {
    fn exec(&self, context: Option<CopPkg>, _: Vec<String>) -> anyhow::Result<Option<CopPkg>> {
        if let Some(context) = &context {
            println!("Status: {} ({}, {})", Color::Green.paint("ok"), context.name, context.version);
        } else {
            println!("Status: {}", Color::Red.paint("not set"));
        }

        Ok(context)
    }
}

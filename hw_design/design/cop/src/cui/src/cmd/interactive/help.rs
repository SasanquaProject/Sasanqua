use ansi_term::Color;

use copgen::pkg::CopPkg;

use super::Executable;

pub struct Help;

impl Executable for Help {
    fn exec(&self, context: Option<CopPkg>, _: Vec<String>) -> anyhow::Result<Option<CopPkg>> {
        println!("{}: Print available cop-impls", Color::Green.paint("list"));
        println!("{}: Reset a package context", Color::Green.paint("new"));
        println!("{}: Print help information", Color::Green.paint("help"));
        println!("{}: Exit this interactive terminal", Color::Green.paint("exit"));

        Ok(context)
    }
}

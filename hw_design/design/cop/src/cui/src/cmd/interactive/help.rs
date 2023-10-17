use ansi_term::Color;

use super::Executable;

pub struct Help;

impl Executable for Help {
    fn exec(&self, _: Vec<String>) -> anyhow::Result<()> {
        println!("{}: Print available cop-impls", Color::Green.paint("list"));
        println!("{}: Print help information", Color::Green.paint("help"));
        println!("{}: Exit this interactive terminal", Color::Green.paint("exit"));

        Ok(())
    }
}

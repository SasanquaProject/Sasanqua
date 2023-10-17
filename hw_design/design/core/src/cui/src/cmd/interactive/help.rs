use ansi_term::Color;

use coregen::sasanqua::Sasanqua;

use super::Executable;

pub struct Help;

impl Executable for Help {
    fn exec(&self, context: Option<Sasanqua>, _: Vec<String>) -> anyhow::Result<Option<Sasanqua>> {
        println!("{}: Reset a generating context", Color::Green.paint("new"));
        println!("{}: Print generating information", Color::Green.paint("status"));
        println!("{}: Generate a core-ip", Color::Green.paint("generate"));
        println!("{}: Print help information", Color::Green.paint("help"));
        println!("{}: Exit this interactive terminal", Color::Green.paint("exit"));

        Ok(context)
    }
}

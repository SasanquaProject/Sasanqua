use ansi_term::Color;

use super::Executable;

use coregen::sasanqua::Sasanqua;

pub struct Status;

impl Executable for Status {
    fn exec(&self, context: Option<Sasanqua>, _: Vec<String>) -> anyhow::Result<Option<Sasanqua>> {
        if let Some(_) = &context {
            println!("Status: {}", Color::Green.paint("ok"));
        } else {
            println!("Status: {}", Color::Red.paint("not set"));
        }

        Ok(context)
    }
}

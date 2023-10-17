use ansi_term::{Color, Style};

use super::Executable;

use copgen::pkg::CopPkg;

pub struct Status;

impl Executable for Status {
    fn exec(&self, context: Option<CopPkg>, _: Vec<String>) -> anyhow::Result<Option<CopPkg>> {
        if let Some(context) = &context {
            println!("Status: {} ({}, {})", Color::Green.paint("ok"), context.name, context.version);
            println!("Cop-Impls:");
            for (idx, profile) in context.profiles.iter().enumerate() {
                let prof_name = format!("{:?}", profile);
                let prof_name = Style::new().italic().paint(prof_name);
                println!("  - Cop#{} = {}", idx, prof_name);
            }
        } else {
            println!("Status: {}", Color::Red.paint("not set"));
        }

        Ok(context)
    }
}

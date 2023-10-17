use ansi_term::Style;

use coregen::sasanqua::Sasanqua;
use coregen::gen_physfs;
use ipgen::vendor::{Any, Xilinx};

use super::Executable;

pub struct Generate;

impl Executable for Generate {
    fn exec(&self, context: Option<Sasanqua>, args: Vec<String>) -> anyhow::Result<Option<Sasanqua>> {
        if context.is_none() {
            println!("A generating context is not set!");
            println!("Execute 'new' command.");
            return Ok(None);
        }

        if args.len() < 2 {
            println!("usage: generate <vendor>");
            return Ok(context);
        }

        let context = context.unwrap();
        match args[1].as_str() {
            "Any" => {
                gen_physfs::<Any, &str>(&context, "core_ip")?;
                println!("Ok");
            },
            "Xilinx" => {
                gen_physfs::<Xilinx, &str>(&context, "core_ip")?;
                println!("Ok");
            },
            v => {
                println!("Vendor '{}' is not implemented.", v);
                println!(
                    "  => availables: {}, {}",
                    Style::new().italic().paint("Any"),
                    Style::new().italic().paint("Xilinx")
                );
            },
        };

        Ok(None)
    }
}

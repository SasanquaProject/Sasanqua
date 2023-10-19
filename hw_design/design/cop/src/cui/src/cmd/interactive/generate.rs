use ansi_term::Style;

use copgen::gen_physfs;
use copgen::pkg::CopPkg;
use ipgen::vendor::{Any, Xilinx};

use super::Executable;

pub struct Generate;

impl Executable for Generate {
    fn exec(&self, context: Option<CopPkg>, args: Vec<String>) -> anyhow::Result<Option<CopPkg>> {
        if context.is_none() {
            println!("A package context is not set!");
            println!("Execute 'new' command.");
            return Ok(None);
        }

        if args.len() < 2 {
            println!("usage: generate <vendor>");
            return Ok(context);
        }

        let context = context.unwrap();
        let dir_name = format!("{}_ip", context.name);
        match args[1].as_str() {
            "Any" => {
                gen_physfs::<Any, String>(context, dir_name)?;
                println!("Ok");
            }
            "Xilinx" => {
                gen_physfs::<Xilinx, String>(context, dir_name)?;
                println!("Ok");
            }
            v => {
                println!("Vendor '{}' is not implemented.", v);
                println!(
                    "  => availables: {}, {}",
                    Style::new().italic().paint("Any"),
                    Style::new().italic().paint("Xilinx")
                );
            }
        };

        Ok(None)
    }
}

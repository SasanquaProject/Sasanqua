use ansi_term::Style;

use super::Executable;

use coregen::sasanqua::bus::AXI4;
use coregen::sasanqua::Sasanqua;

pub struct New;

impl Executable for New {
    fn exec(
        &self,
        context: Option<Sasanqua>,
        args: Vec<String>,
    ) -> anyhow::Result<Option<Sasanqua>> {
        if args.len() < 2 {
            println!("usage: new <bus_if>");
            return Ok(None);
        }

        let context = match args[1].as_str() {
            "AXI4" => {
                println!("Ok");
                Some(Sasanqua::new(AXI4))
            }
            bus_if => {
                println!("BusIF '{}' is not found.", bus_if);
                println!("  => availables: {}", Style::new().italic().paint("AXI4"));
                context
            }
        };

        Ok(context)
    }
}

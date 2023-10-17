mod not_found;
mod help;

use std::io::{stdin, stdout};
use std::io::Write;

use clap::Parser;

#[derive(Parser)]
pub struct InteractiveCmd;

impl InteractiveCmd {
    pub fn run(&self) -> anyhow::Result<()> {
        loop {
            if let Some((cmd, args)) = parse_stdin()? {
                cmd.exec(args)?;
                println!("");
                continue
            }
            return Ok(());
        }
    }
}

pub(super) trait Executable
where
    Self: 'static
{
    fn exec(&self, ext_args: Vec<String>) -> anyhow::Result<()>;
}

fn parse_stdin() -> anyhow::Result<Option<(Box<dyn Executable>, Vec<String>)>> {
    print!("> ");
    stdout().flush()?;

    let mut input = String::new();
    stdin().read_line(&mut input)?;
    let args: Vec<String> = input.trim().split(" ").map(|s| s.to_string()).collect();

    match args[0].as_str() {
        "help" => Ok(Some((Box::new(help::Help), args))),
        "exit" => Ok(None),
        _ => Ok(Some((Box::new(not_found::NotFound), args))),
    }
}

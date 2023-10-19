mod generate;
mod help;
mod new;
mod not_found;
mod status;

use std::io::Write;
use std::io::{stdin, stdout};

use clap::Parser;

use coregen::sasanqua::Sasanqua;

#[derive(Parser)]
pub struct InteractiveCmd;

impl InteractiveCmd {
    pub fn run(&self) -> anyhow::Result<()> {
        let mut context: Option<Sasanqua> = None;
        loop {
            if let Some((cmd, args)) = parse_stdin()? {
                context = cmd.exec(context, args)?;
                println!("");
                continue;
            }
            return Ok(());
        }
    }
}

pub(super) trait Executable
where
    Self: 'static,
{
    fn exec(
        &self,
        context: Option<Sasanqua>,
        args: Vec<String>,
    ) -> anyhow::Result<Option<Sasanqua>>;
}

fn parse_stdin() -> anyhow::Result<Option<(Box<dyn Executable>, Vec<String>)>> {
    print!("> ");
    stdout().flush()?;

    let mut input = String::new();
    stdin().read_line(&mut input)?;
    let args: Vec<String> = input.trim().split(" ").map(|s| s.to_string()).collect();

    match args[0].as_str() {
        "new" => Ok(Some((Box::new(new::New), args))),
        "status" => Ok(Some((Box::new(status::Status), args))),
        "generate" => Ok(Some((Box::new(generate::Generate), args))),
        "help" => Ok(Some((Box::new(help::Help), args))),
        "exit" => Ok(None),
        _ => Ok(Some((Box::new(not_found::NotFound), args))),
    }
}

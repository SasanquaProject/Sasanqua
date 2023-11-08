mod add;
mod generate;
mod new;
mod status;
mod not_found;
mod help;
mod list;

use std::io::Write;
use std::io::{stdin, stdout};

use clap::Parser;

use copgen::pkg::CopPkg;

#[derive(Parser)]
pub struct InteractiveCmd;

impl InteractiveCmd {
    pub fn run(&self) -> anyhow::Result<()> {
        println!(r#"
  _________  ____  ____ ____  ____
 / ___/ __ \/ __ \/ __ `/ _ \/ __ \
/ /__/ /_/ / /_/ / /_/ /  __/ / / /
\___/\____/ .___/\__, /\___/_/ /_/
         /_/    /____/

Type "help" for more information.
        "#);

        let mut context: Option<CopPkg> = None;
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
    fn exec(&self, context: Option<CopPkg>, args: Vec<String>) -> anyhow::Result<Option<CopPkg>>;
}

fn parse_stdin() -> anyhow::Result<Option<(Box<dyn Executable>, Vec<String>)>> {
    print!(">> ");
    stdout().flush()?;

    let mut input = String::new();
    stdin().read_line(&mut input)?;
    let args: Vec<String> = input.trim().split(" ").map(|s| s.to_string()).collect();

    match args[0].as_str() {
        "new" => Ok(Some((Box::new(new::New), args))),
        "add" => Ok(Some((Box::new(add::Add), args))),
        "status" => Ok(Some((Box::new(status::Status), args))),
        "generate" => Ok(Some((Box::new(generate::Generate), args))),
        "list" => Ok(Some((Box::new(list::List), args))),
        "help" => Ok(Some((Box::new(help::Help), args))),
        "exit" => Ok(None),
        _ => Ok(Some((Box::new(not_found::NotFound), args))),
    }
}

mod generate;
mod help;
mod new;
mod not_found;
mod status;

use std::io::Write;
use std::io::{stdin, stdout};

use ansi_term::Color;
use clap::Parser;

use coregen::sasanqua::Sasanqua;

#[derive(Parser)]
pub struct InteractiveCmd;

impl InteractiveCmd {
    pub fn run(&self) -> anyhow::Result<()> {
        println!(r#"
  _________  ________  ____ ____  ____
 / ___/ __ \/ ___/ _ \/ __ `/ _ \/ __ \
/ /__/ /_/ / /  /  __/ /_/ /  __/ / / /
\___/\____/_/   \___/\__, /\___/_/ /_/
                    /____/

Type "help" for more information.
Type "status" to check generating status.
        "#);

        let mut context: Option<Sasanqua> = None;
        loop {
            let stat_c = match context {
                Some(_) => Color::Green.paint("o"),
                None => Color::Red.paint("x"),
            };
            print!("({})>> ", stat_c);
            stdout().flush().unwrap();

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
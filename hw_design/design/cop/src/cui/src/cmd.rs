use clap::{AppSettings, Parser, Subcommand};

/// Cop-IP Generator - CUI
#[derive(Parser)]
#[clap(author, version, name = "copgen_cui")]
#[clap(global_settings(&[AppSettings::DisableHelpSubcommand]))]
pub struct App {
    #[clap(subcommand)]
    sub: AppSub,
}

#[derive(Subcommand)]
#[allow(non_camel_case_types)]
enum AppSub {
    Tmp,
}

impl App {
    pub fn run() -> anyhow::Result<()> {
        let result: anyhow::Result<()> = match App::parse().sub {
            _ => Ok(()),
        };
        match result {
            Ok(_) => Ok(()),
            err@Err(_) => err,
        }
    }
}

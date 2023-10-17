use clap::Parser;

#[derive(Parser)]
pub struct InteractiveCmd;

impl InteractiveCmd {
    pub fn run(&self) -> anyhow::Result<()> {
        Ok(())
    }
}

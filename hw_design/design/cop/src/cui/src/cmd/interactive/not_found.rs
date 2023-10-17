use super::Executable;

pub struct NotFound;

impl Executable for NotFound {
    fn exec(&self, args: Vec<String>) -> anyhow::Result<()> {
        println!("Not Found : '{}'", args[0]);
        Ok(())
    }
}

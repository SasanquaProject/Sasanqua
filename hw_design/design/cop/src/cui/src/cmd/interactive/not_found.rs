use super::Executable;

use copgen::pkg::CopPkg;

pub struct NotFound;

impl Executable for NotFound {
    fn exec(&self, context: Option<CopPkg>, args: Vec<String>) -> anyhow::Result<Option<CopPkg>> {
        println!("Not Found : '{}'", args[0]);
        Ok(context)
    }
}

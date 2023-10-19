use super::Executable;

use coregen::sasanqua::Sasanqua;

pub struct NotFound;

impl Executable for NotFound {
    fn exec(
        &self,
        context: Option<Sasanqua>,
        args: Vec<String>,
    ) -> anyhow::Result<Option<Sasanqua>> {
        println!("Not Found : '{}'", args[0]);
        Ok(context)
    }
}

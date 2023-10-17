use coregen::sasanqua::Sasanqua;
use coregen::gen_physfs;

use super::Executable;

pub struct Generate;

impl Executable for Generate {
    fn exec(&self, context: Option<Sasanqua>, _: Vec<String>) -> anyhow::Result<Option<Sasanqua>> {
        if context.is_none() {
            println!("A generating context is not set!");
            println!("Execute 'new' command.");
            return Ok(None);
        }

        let context = context.unwrap();
        gen_physfs(&context, "core_ip")?;
        println!("Ok");

        Ok(None)
    }
}

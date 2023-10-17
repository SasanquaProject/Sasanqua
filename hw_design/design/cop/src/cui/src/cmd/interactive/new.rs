use super::Executable;

use copgen::pkg::CopPkg;

pub struct New;

impl Executable for New {
    fn exec(&self, context: Option<CopPkg>, args: Vec<String>) -> anyhow::Result<Option<CopPkg>> {
        if args.len() < 3 {
            println!("usage: new <name> <version>");
            Ok(context)
        } else {
            println!("Ok");
            Ok(Some(CopPkg::new(
                args.get(1).unwrap(),
                args.get(2).unwrap()
            )))
        }
    }
}

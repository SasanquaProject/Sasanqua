use super::Executable;

use copgen::pkg::CopPkg;
use std_cops::Rv32iMini;
use verilog_cops::Void;

pub struct Add;

impl Executable for Add {
    fn exec(&self, context: Option<CopPkg>, args: Vec<String>) -> anyhow::Result<Option<CopPkg>> {
        if context.is_none() {
            println!("A package context is not set!");
            println!("Execute 'new' command.");
            return Ok(None);
        }

        if args.len() < 2 {
            println!("usage: add <cop_impl>");
            return Ok(context);
        }

        let context = context.unwrap();
        let context = match args[1].as_str() {
            "rv32i_mini" => {
                println!("Ok");
                context.add_cop(Rv32iMini)
            },
            "void" => {
                println!("Ok");
                context.add_cop(Void)
            },
            cop_impl => {
                println!("Cop-Impl '{}' is not found.", cop_impl);
                println!("Please check 'list' command.");
                context
            },
        };

        Ok(Some(context))
    }
}

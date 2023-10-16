use serde::Serialize;
use tinytemplate::{format_unescaped, TinyTemplate};

use crate::{CopPkg, CopProfile};

const COP_V: &'static str = include_str!("../hw/src/cop.v");
const COP_DEC_MODULE_V: &'static str = include_str!("../hw/src/cop_dec_module.v");

pub(crate) fn gen_pkg(cop_pkg: CopPkg) -> anyhow::Result<String> {
    let module_declares = cop_pkg
        .profiles
        .into_iter()
        .enumerate()
        .map(|item| DeclareModuleTemplate::from(item).gen(COP_DEC_MODULE_V))
        .collect::<anyhow::Result<Vec<String>>>()?;

    TopTemplate::from(module_declares).gen(COP_V)
}

trait TextGeneratable
where
    Self: Serialize + Sized,
{
    fn gen(self, template: &'static str) -> anyhow::Result<String> {
        let mut tt = TinyTemplate::new();
        tt.set_default_formatter(&format_unescaped);
        tt.add_template("Template", template)?;
        Ok(tt.render("Template", &self)?)
    }
}

#[allow(non_snake_case)]
#[derive(Serialize)]
struct TopTemplate {
    MODULE_DECLARES: String,
}

impl TextGeneratable for TopTemplate {}

impl From<Vec<String>> for TopTemplate {
    fn from(module_declares: Vec<String>) -> Self {
        let formatted = module_declares
            .into_iter()
            .enumerate()
            .map(|(id, s)| format!("/*----- Cop{} ----- */\n{}", id, s))
            .collect::<Vec<String>>()
            .join("\n\n");

        TopTemplate {
            MODULE_DECLARES: formatted,
        }
    }
}

#[allow(non_snake_case)]
#[derive(Serialize)]
struct DeclareModuleTemplate {
    DEC_ID: i32,
    DEC_NAME: String,
}

impl TextGeneratable for DeclareModuleTemplate {}

impl From<(usize, Box<dyn CopProfile>)> for DeclareModuleTemplate {
    fn from((id, profile): (usize, Box<dyn CopProfile>)) -> Self {
        DeclareModuleTemplate {
            DEC_ID: id as i32,
            DEC_NAME: profile.name(),
        }
    }
}

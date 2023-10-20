use serde::Serialize;

use crate::pkg::CopPkg;
use crate::utils::TextGeneratable;

const COP_V: &'static str = include_str!("../../template/src/cop.v");
const COP_DEC_MODULE_V: &'static str = include_str!("../../template/src/cop_dec_module.v");

pub(crate) fn gen_pkg(cop_pkg: &CopPkg) -> anyhow::Result<String> {
    let module_declares = cop_pkg
        .profiles
        .iter()
        .enumerate()
        .map(|(id, _)| DeclareModuleTemplate::from(id).gen(COP_DEC_MODULE_V))
        .collect::<anyhow::Result<Vec<String>>>()?;

    TopTemplate::from(module_declares).gen(COP_V)
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
}

impl TextGeneratable for DeclareModuleTemplate {}

impl From<usize> for DeclareModuleTemplate {
    fn from(id: usize) -> Self {
        DeclareModuleTemplate { DEC_ID: id as i32 }
    }
}

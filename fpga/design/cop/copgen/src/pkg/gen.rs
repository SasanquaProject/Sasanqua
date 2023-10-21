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
    COMBINE_RESULTS: String,
    MODULE_DECLARES: String,
}

impl TextGeneratable for TopTemplate {}

impl From<Vec<String>> for TopTemplate {
    fn from(module_declares: Vec<String>) -> Self {
        let combine_targets = vec![
            "C_O_ACCEPT",
            "E_O_ALLOW",
            "E_O_VALID",
            "E_O_PC",
            "E_O_REG_W_EN",
            "E_O_REG_W_RD",
            "E_O_REG_W_DATA",
            "E_O_EXC_EN",
            "E_O_EXC_CODE",
        ];
        let combine_results = combine_targets
            .into_iter()
            .map(|wire| (wire, wire.to_lowercase()))
            .map(|(wire, lwire)| (wire, TopTemplate::conbine(&lwire, module_declares.len())))
            .map(|(wire, combined)| format!("assign {} = {};\n", wire, combined))
            .collect();

        let module_declares = module_declares
            .into_iter()
            .enumerate()
            .map(|(id, s)| format!("/*----- Cop{} ----- */\n{}", id, s))
            .collect::<Vec<String>>()
            .join("\n\n");

        TopTemplate {
            COMBINE_RESULTS: combine_results,
            MODULE_DECLARES: module_declares,
        }
    }
}

impl TopTemplate {
    fn conbine(prefix: &str, len: usize) -> String {
        let combined = (0..len)
            .rev()
            .map(|idx| format!("{}_{}", prefix, idx))
            .collect::<Vec<String>>()
            .join(",");

        format!("{{ {} }}", combined)
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

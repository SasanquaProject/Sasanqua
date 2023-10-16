use serde::Serialize;

use crate::profile::CopProfile;
use crate::utils::TextGeneratable;

const COP_IMPL_V: &'static str = include_str!("../../template/src/cop_impl.v");

pub fn gen_impl_vs(profiles: &Vec<Box<dyn CopProfile>>) -> anyhow::Result<Vec<String>> {
    profiles
        .into_iter()
        .enumerate()
        .map(|(id, profile)| TopTemplate::from((id, profile)).gen(COP_IMPL_V))
        .collect()
}

#[allow(non_snake_case)]
#[derive(Serialize)]
struct TopTemplate {
    ID: usize,
    INST_PARAMETERS: String,
    INST_CHECK_CONDS: String,
    READY_HDL: String,
    EXEC_HDL: String,
}

impl TextGeneratable for TopTemplate {}

impl From<(usize, &Box<dyn CopProfile>)> for TopTemplate {
    fn from((id, profile): (usize, &Box<dyn CopProfile>)) -> Self {
        let (inst_parameters, inst_check_conds) = profile
            .opcodes()
            .into_iter()
            .enumerate()
            .map(|(idx, (tag, opcode))| {
                let parameter = format!("parameter {} = 32'd{};", tag, idx + 1);
                let check_cond = format!("{}: check_inst = {};", opcode, tag);
                (parameter, check_cond)
            })
            .fold(("".to_string(), "".to_string()), |(ps, cs), (p, c)| {
                (ps + "\n" + &p, cs + "\n" + &c)
            });
        let cop_impl = profile.body();

        TopTemplate {
            ID: id,
            INST_PARAMETERS: inst_parameters,
            INST_CHECK_CONDS: inst_check_conds,
            READY_HDL: cop_impl.ready,
            EXEC_HDL: cop_impl.exec,
        }
    }
}

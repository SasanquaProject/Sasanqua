mod cop_impl;
mod inst;
mod gen;

pub use cop_impl::{CopImpl, CopImplTemplate};
pub(crate) use gen::gen;
pub use inst::OpCode;

pub trait CopProfile {
    fn name(&self) -> String;
    fn opcodes(&self) -> Vec<(&'static str, OpCode)>;
    fn body(&self) -> CopImpl;
}

mod cop_impl;
mod inst;
mod gen;

use std::fmt::Debug;

pub use cop_impl::{CopImpl, CopImplTemplate};
pub(crate) use gen::gen_impl_vs;
pub use inst::OpCode;

pub trait CopProfile
where
    Self: Debug,
{
    fn opcodes(&self) -> Vec<(&'static str, OpCode)>;
    fn body(&self) -> CopImpl;
}

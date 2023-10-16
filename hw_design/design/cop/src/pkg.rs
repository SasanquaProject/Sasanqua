mod check;
mod gen;

use crate::profile::CopProfile;

#[derive(Default)]
pub struct CopPkg {
    pub(crate) profiles: Vec<Box<dyn CopProfile>>,
}

impl CopPkg {
    pub fn add_cop<C>(mut self, cop_profile: C) -> Self
    where
        C: CopProfile + 'static,
    {
        self.profiles.push(Box::new(cop_profile));
        self
    }

    pub(crate) fn gen(self) -> anyhow::Result<String> {
        check::check_pkg(&self)?;
        gen::gen_pkg(self)
    }
}

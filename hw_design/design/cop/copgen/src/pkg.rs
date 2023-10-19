mod check;
mod gen;

use crate::profile::CopProfile;

pub struct CopPkg {
    pub name: String,
    pub version: String,
    pub profiles: Vec<Box<dyn CopProfile>>,
}

impl CopPkg {
    pub fn new<S: Into<String>>(name: S, version: S) -> Self {
        CopPkg {
            name: name.into(),
            version: version.into(),
            profiles: vec![],
        }
    }

    pub fn add_cop<C>(mut self, cop_profile: C) -> Self
    where
        C: CopProfile + 'static,
    {
        self.profiles.push(Box::new(cop_profile));
        self
    }

    pub(crate) fn gen(&self) -> anyhow::Result<String> {
        check::check_pkg(&self)?;
        gen::gen_pkg(&self)
    }
}

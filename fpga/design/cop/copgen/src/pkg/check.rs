use crate::pkg::CopPkg;
use crate::profile::CopProfile;

pub(crate) fn check_pkg(cop_pkg: &CopPkg) -> anyhow::Result<()> {
    for profile in cop_pkg.profiles.iter() {
        check_profile(profile)?;
    }
    Ok(())
}

fn check_profile(_: &Box<dyn CopProfile>) -> anyhow::Result<()> {
    Ok(())
}

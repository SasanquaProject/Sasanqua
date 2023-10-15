use crate::{CopPkg, CopProfile};

pub(crate) fn gen_pkg(cop_pkg: CopPkg) -> () {
    let profiles = cop_pkg.profiles;
    let _profiles = profiles.into_iter()
        .map(|profile| gen_profile(profile))
        .collect::<Vec<()>>();
    ()
}

fn gen_profile(_: Box<dyn CopProfile>) -> () {
    ()
}

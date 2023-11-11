use std::fs;
use std::path::Path;

use slint::{Weak, SharedString};

use copgen::pkg::CopPkg;
use copgen::gen_physfs;
use ipgen::vendor::{Any, Xilinx};
use std_cops::Rv32iMini;
use verilog_cops::Void;

use crate::MainWindow;

#[derive(Debug)]
struct Cop {
    // General
    name: String,
    version: String,

    // Impls
    impl_set: CopImplSet,

    // Output
    vendor: Vendor,
    path: String,
    do_create_subdir: bool,
    do_overwrite: bool,
}

impl Cop {
    fn from(window: Weak<MainWindow>) -> anyhow::Result<Self> {
        let cop = Cop {
            name: window.unwrap().get_name().into(),
            version: window.unwrap().get_version().into(),
            impl_set: CopImplSet::from(window.clone())?,
            vendor: Vendor::from(window.unwrap().get_vendor())?,
            path: window.unwrap().get_path().into(),
            do_create_subdir: window.unwrap().get_do_create_subdir(),
            do_overwrite: window.unwrap().get_do_overwrite(),
        };

        if cop.name.len() * cop.version.len() * cop.path.len() > 0 {
            Ok(cop)
        } else {
            Err(anyhow::format_err!("All values must be filled!"))
        }
    }
}

#[derive(Debug)]
struct CopImplSet {
    // RISC-V Standards
    rv32i_mini: i32,

    // Others
    void: i32,
}

impl CopImplSet {
    fn from(window: Weak<MainWindow>) -> anyhow::Result<Self> {
        let impl_set = CopImplSet {
            rv32i_mini: window.unwrap().get_rv32i_mini_cnt(),
            void: window.unwrap().get_void_cnt(),
        };

        if impl_set.rv32i_mini + impl_set.void > 0 {
            Ok(impl_set)
        } else {
            Err(anyhow::format_err!("Coppkg must contain at least one cop-impl."))
        }
    }
}

#[derive(Debug)]
enum Vendor {
    Any,
    Xilinx,
}

impl Vendor {
    fn from(s: SharedString) -> anyhow::Result<Self> {
        match s.as_str() {
            "Any" => Ok(Vendor::Any),
            "Xilinx" => Ok(Vendor::Xilinx),
            _ => Err(anyhow::format_err!("not implemented")),
        }
    }
}

pub fn generate(window: Weak<MainWindow>) -> anyhow::Result<()> {
    macro_rules! impl_n {
        ($($pkg:ident += $profile:ident * $n:expr);*) => {
            $(
                for _ in 0..$n {
                    $pkg = $pkg.add_cop($profile);
                }
            )*
        };
    }

    let cop = Cop::from(window.clone())?;

    let mut cop_pkg = CopPkg::new(&cop.name, &cop.version);
    impl_n! {
        cop_pkg += Rv32iMini * cop.impl_set.rv32i_mini;
        cop_pkg += Void * cop.impl_set.void
    }

    let dir_path = if cop.do_create_subdir {
        format!("{}/{}", cop.path, cop.name)
    } else {
        format!("{}", cop.path)
    };
    if Path::new(&dir_path).exists() {
        if cop.do_overwrite {
            fs::remove_dir_all(&dir_path)?;
        } else {
            return Err(anyhow::format_err!("Path \"{}\" is already exists.", dir_path));
        }
    }

    match cop.vendor {
        Vendor::Any => { gen_physfs::<Any, String>(cop_pkg, dir_path)?; }
        Vendor::Xilinx => { gen_physfs::<Xilinx, String>(cop_pkg, dir_path)?; }
    }

    Ok(())
}

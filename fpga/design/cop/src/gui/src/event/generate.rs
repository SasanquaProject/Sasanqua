use std::fs;
use std::path::Path;
use std::thread;
use std::time::Duration;

use copgen::pkg::CopPkg;
use copgen::gen_physfs;
use ipgen::vendor::{Any, Xilinx};
use std_cops::Rv32iMini;
use verilog_cops::Void;

use crate::ui::input::Vendor;
use crate::ui::{input, output};

pub fn generate(input: input::UI) -> anyhow::Result<output::UI> {
    macro_rules! impl_n {
        ($($pkg:ident += $profile:ident * $n:expr);*) => {
            $(
                for _ in 0..$n {
                    $pkg = $pkg.add_cop($profile);
                }
            )*
        };
    }

    let mut cop_pkg = CopPkg::new(&input.name, &input.version);
    impl_n! {
        cop_pkg += Rv32iMini * input.impl_set.rv32i_mini;
        cop_pkg += Void * input.impl_set.void
    }
    if cop_pkg.profiles.len() == 0 {
        return Err(anyhow::format_err!("Coppkg must contain at least one cop-impl."))
    }

    let dir_path = if input.do_create_subdir {
        format!("{}/{}", input.path, input.name)
    } else {
        format!("{}", input.path)
    };
    if Path::new(&dir_path).exists() {
        if input.do_overwrite {
            fs::remove_dir_all(&dir_path)?;
        } else {
            return Err(anyhow::format_err!("Path \"{}\" is already exists.", dir_path));
        }
    }

    match input.vendor {
        Vendor::Any => { gen_physfs::<Any, String>(cop_pkg, dir_path)?; }
        Vendor::Xilinx => { gen_physfs::<Xilinx, String>(cop_pkg, dir_path)?; }
    }

    thread::sleep(Duration::from_secs(1));

    Ok(output::UI::from(input))
}

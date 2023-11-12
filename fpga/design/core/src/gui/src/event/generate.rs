use std::fs;
use std::path::Path;
use std::thread;
use std::time::Duration;

use coregen::sasanqua::bus::AXI4;
use coregen::sasanqua::Sasanqua;
use coregen::gen_physfs;
use ipgen::vendor::{Any, Xilinx};

use crate::ui::input::{BusInterface, Vendor};
use crate::ui::{input, output};

pub fn generate(input: input::UI) -> anyhow::Result<output::UI> {
    let (dir_path, ) = check(&input)?;

    let sasanqua = match input.bus {
        BusInterface::AXI4 => Sasanqua::new(AXI4),
    };

    match input.vendor {
        Vendor::Any => { gen_physfs::<Any, String>(&sasanqua, dir_path)?; },
        Vendor::Xilinx => { gen_physfs::<Xilinx, String>(&sasanqua, dir_path)?; },
    }

    thread::sleep(Duration::from_secs(1));

    Ok(output::UI::from(input))
}

fn check(input: &input::UI) -> anyhow::Result<(String, )> {
    // Check form status
    if input.name.len() * input.version.len() * input.path.len() == 0 {
        return Err(anyhow::format_err!("All values must be filled."));
    }

    // Check directory
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

    Ok((dir_path, ))
}

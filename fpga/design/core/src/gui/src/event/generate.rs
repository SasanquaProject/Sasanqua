use std::fs;
use std::path::Path;

use slint::{Weak, SharedString};

use coregen::sasanqua::bus::AXI4;
use coregen::sasanqua::Sasanqua;
use coregen::gen_physfs;
use ipgen::vendor::{Any, Xilinx};

use crate::MainWindow;

#[derive(Debug)]
struct Core {
    // General
    name: String,
    version: String,

    // Core
    bus: BusInterface,

    // Output
    vendor: Vendor,
    path: String,
    do_create_subdir: bool,
    do_overwrite: bool,
}

impl Core {
    fn from(window: Weak<MainWindow>) -> anyhow::Result<Self> {
        let core = Core {
            name: window.unwrap().get_name().into(),
            version: window.unwrap().get_version().into(),
            bus: BusInterface::from(window.clone().unwrap().get_bus())?,
            vendor: Vendor::from(window.unwrap().get_vendor())?,
            path: window.unwrap().get_path().into(),
            do_create_subdir: window.unwrap().get_do_create_subdir(),
            do_overwrite: window.unwrap().get_do_overwrite(),
        };

        if core.name.len() * core.version.len() * core.path.len() > 0 {
            Ok(core)
        } else {
            Err(anyhow::format_err!("All values be must filled!"))
        }
    }
}

#[derive(Debug)]
enum BusInterface {
    AXI4,
}

impl BusInterface {
    fn from(s: SharedString) -> anyhow::Result<Self> {
        match s.as_str() {
            "AXI4" => Ok(BusInterface::AXI4),
            _ => Err(anyhow::format_err!("not implemented")),
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
    let core = Core::from(window.clone())?;

    let sasanqua = match core.bus {
        BusInterface::AXI4 => Sasanqua::new(AXI4),
    };

    let dir_path = if core.do_create_subdir {
        format!("{}/{}", core.path, core.name)
    } else {
        format!("{}", core.path)
    };
    if Path::new(&dir_path).exists() {
        if core.do_overwrite {
            fs::remove_dir_all(&dir_path)?;
        } else {
            return Err(anyhow::format_err!("Path \"{}\" is already exists.", dir_path));
        }
    }

    match core.vendor {
        Vendor::Any => { gen_physfs::<Any, String>(&sasanqua, dir_path)?; },
        Vendor::Xilinx => { gen_physfs::<Xilinx, String>(&sasanqua, dir_path)?; },
    }

    Ok(())
}

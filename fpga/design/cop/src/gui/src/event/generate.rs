use std::fs;
use std::path::Path;

use slint::{Weak, SharedString};

use crate::MainWindow;

#[derive(Debug)]
struct Cop {
    // General
    name: String,
    version: String,

    // Cop
    bus: BusInterface,

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
            bus: BusInterface::from(window.clone().unwrap().get_bus())?,
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
    let cop = Cop::from(window.clone())?;
    println!("{:?}", cop);

    // let dir_path = if cop.do_create_subdir {
    //     format!("{}/{}", cop.path, cop.name)
    // } else {
    //     format!("{}", cop.path)
    // };
    // if Path::new(&dir_path).exists() {
    //     if cop.do_overwrite {
    //         fs::remove_dir_all(&dir_path)?;
    //     } else {
    //         return Err(anyhow::format_err!("Path \"{}\" is already exists.", dir_path));
    //     }
    // }

    Ok(())
}

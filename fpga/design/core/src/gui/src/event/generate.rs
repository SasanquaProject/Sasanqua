use slint::{Weak, SharedString};

use crate::MainWindow;

#[derive(Debug)]
pub struct Core {
    // General
    name: String,
    version: String,

    // Core
    bus: BusInterface,

    // Output
    path: String,
    do_create_subdir: bool,
    do_overwrite: bool,
}

impl From<Weak<MainWindow>> for Core {
    fn from(window: Weak<MainWindow>) -> Self {
        Core {
            name: window.unwrap().get_name().into(),
            version: window.unwrap().get_version().into(),
            bus: BusInterface::from(window.unwrap().get_bus()),
            path: window.unwrap().get_path().into(),
            do_create_subdir: window.unwrap().get_do_create_subdir(),
            do_overwrite: window.unwrap().get_do_overwrite(),
        }
    }
}

#[derive(Debug)]
enum BusInterface {
    Any,
    Xilinx,
}

impl From<SharedString> for BusInterface {
    fn from(s: SharedString) -> Self {
        match s.as_str() {
            "Any" => BusInterface::Any,
            "Xilinx" => BusInterface::Xilinx,
            _ => unimplemented!(),
        }
    }
}

pub fn generate(core: Core) -> anyhow::Result<()> {
    println!("{:?}", core);

    Ok(())
}

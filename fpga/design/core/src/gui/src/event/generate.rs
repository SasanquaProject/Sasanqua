use slint::{Weak, SharedString};

use crate::MainWindow;

#[derive(Debug)]
struct Core {
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

impl Core {
    fn from(window: Weak<MainWindow>) -> anyhow::Result<Self> {
        let core = Core {
            name: window.unwrap().get_name().into(),
            version: window.unwrap().get_version().into(),
            bus: BusInterface::from(window.unwrap().get_bus()),
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

pub fn generate(window: Weak<MainWindow>) -> anyhow::Result<()> {
    let core = Core::from(window.clone())?;
    println!("{:?}", core);

    Ok(())
}

use slint::{SharedString, Weak};

use crate::MainWindow;

#[derive(Debug, Clone)]
pub struct UI {
    // General
    pub name: String,
    pub version: String,

    // Core
    pub bus: BusInterface,

    // Output
    pub vendor: Vendor,
    pub path: String,
    pub do_create_subdir: bool,
    pub do_overwrite: bool,
}

impl From<Weak<MainWindow>> for UI {
    fn from(window: Weak<MainWindow>) -> Self {
        UI {
            name: window.unwrap().get_name().into(),
            version: window.unwrap().get_version().into(),
            bus: BusInterface::from(window.clone().unwrap().get_bus()),
            vendor: Vendor::from(window.unwrap().get_vendor()),
            path: window.unwrap().get_path().into(),
            do_create_subdir: window.unwrap().get_do_create_subdir(),
            do_overwrite: window.unwrap().get_do_overwrite(),
        }
    }
}

#[derive(Debug, Clone)]
pub enum BusInterface {
    AXI4,
}

impl From<SharedString> for BusInterface {
    fn from(s: SharedString) -> Self {
        match s.as_str() {
            "AXI4" => BusInterface::AXI4,
            _ => unimplemented!(),
        }
    }
}

#[derive(Debug, Clone)]
pub enum Vendor {
    Any,
    Xilinx,
}

impl From<SharedString> for Vendor {
    fn from(s: SharedString) -> Self {
        match s.as_str() {
            "Any" => Vendor::Any,
            "Xilinx" => Vendor::Xilinx,
            _ => unimplemented!(),
        }
    }
}

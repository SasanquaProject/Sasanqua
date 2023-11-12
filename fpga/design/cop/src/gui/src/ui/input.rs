use slint::{SharedString, Weak};

use crate::MainWindow;

#[derive(Debug, Clone)]
pub struct UI {
    // General
    pub name: String,
    pub version: String,

    // Impls
    pub impl_set: CopImplSet,

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
            impl_set: CopImplSet::from(window.clone()),
            vendor: Vendor::from(window.unwrap().get_vendor()),
            path: window.unwrap().get_path().into(),
            do_create_subdir: window.unwrap().get_do_create_subdir(),
            do_overwrite: window.unwrap().get_do_overwrite(),
        }
    }
}

#[derive(Debug, Clone)]
pub struct CopImplSet {
    // RISC-V Standards
    pub rv32i_mini: i32,

    // Others
    pub void: i32,
}

impl From<Weak<MainWindow>> for CopImplSet {
    fn from(window: Weak<MainWindow>) -> Self {
        CopImplSet {
            rv32i_mini: window.unwrap().get_rv32i_mini_cnt(),
            void: window.unwrap().get_void_cnt(),
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

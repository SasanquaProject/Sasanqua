pub use driver::gen;

pub mod prelude {
    pub use hwgen::prelude::*;
    pub use ipgen::prelude::*;
}

pub mod sasanqua {
    pub use hwgen::sasanqua::*;
}

pub mod vendor {
    pub use ipgen::vendor::Xilinx;
}

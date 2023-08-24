mod axi;

pub use axi::AXI4;

pub trait BusInterface
where
    Self: std::fmt::Debug,
{}

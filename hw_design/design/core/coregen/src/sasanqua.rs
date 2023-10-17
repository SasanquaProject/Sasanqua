pub mod bus;

use std::marker::PhantomData;

use bus::BusInterface;

#[derive(Debug)]
pub struct Sasanqua<B: BusInterface> {
    pub bus_if: PhantomData<B>,
}

impl<B: BusInterface> Sasanqua<B> {
    #[allow(unused_variables)]
    pub fn new(bus_if: B) -> Sasanqua<B> {
        Sasanqua {
            bus_if: PhantomData,
        }
    }
}

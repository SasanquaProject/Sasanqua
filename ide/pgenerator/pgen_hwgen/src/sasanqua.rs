pub mod bus;

use std::marker::PhantomData;

use bus::BusInterface;

#[derive(Debug)]
pub struct Sasanqua<B>
where
    B: BusInterface,
{
    pub bus_if: PhantomData<B>,
}

impl<B> Sasanqua<B>
where
    B: BusInterface,
{
    #[allow(unused_variables)]
    pub fn new(bus_if: B) -> Sasanqua<B> {
        Sasanqua {
            bus_if: PhantomData,
        }
    }
}

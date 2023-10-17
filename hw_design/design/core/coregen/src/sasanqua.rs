pub mod bus;

use bus::BusInterface;

#[derive(Debug)]
pub struct Sasanqua {
    pub bus_if: Box<dyn BusInterface>,
}

impl Sasanqua {
    #[allow(unused_variables)]
    pub fn new<B>(bus_if: B) -> Sasanqua
    where
        B: BusInterface + 'static,
    {
        Sasanqua {
            bus_if: Box::new(bus_if),
        }
    }
}

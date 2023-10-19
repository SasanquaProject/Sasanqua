mod address_space;
mod bus_interface;
mod file_set;
mod model;
mod parameter;

use serde::{Serialize, Deserialize};

use crate::IPInfo;
pub use address_space::AddressSpaces;
pub use bus_interface::BusInterfaces;
pub use file_set::FileSets;
pub use model::Model;
pub use parameter::Parameters;

pub fn gen_ip_xact_xml(_ipinfo: &IPInfo) -> String {
    quick_xml::se::to_string(&IPXact::default()).unwrap()
}

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename = "component", rename_all = "camelCase")]
struct IPXact {
    vendor: String,
    library: String,
    user: String,
    version: String,
    description: String,
    bus_interfaces: BusInterfaces,
    address_spaces: AddressSpaces,
    model: Model,
    file_sets: FileSets,
    parameters: Parameters,
}

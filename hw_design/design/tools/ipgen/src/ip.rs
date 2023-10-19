mod address_space;
mod bus_interface;
mod file_set;
mod model;
mod parameter;

use serde::{Serialize, Deserialize};

pub use address_space::AddressSpaces;
pub use bus_interface::BusInterfaces;
pub use file_set::FileSets;
pub use model::Model;
pub use parameter::Parameters;

pub fn gen_ip_xact_xml(ipinfo: &IPInfo) -> String {
    quick_xml::se::to_string(ipinfo).unwrap()
}

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename = "component", rename_all = "camelCase")]
pub struct IPInfo {
    pub(crate) vendor: String,
    pub(crate) library: String,
    pub(crate) name: String,
    pub(crate) version: String,
    pub(crate) description: String,
    pub(crate) bus_interfaces: BusInterfaces,
    pub(crate) address_spaces: AddressSpaces,
    pub(crate) model: Model,
    pub(crate) file_sets: FileSets,
    pub(crate) parameters: Parameters,
}

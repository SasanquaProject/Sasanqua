use serde::Serialize;

use crate::IPInfo;

pub fn gen_ip_xact_xml(ipinfo: &IPInfo) -> String {
    serde_xml_rs::to_string(&IPXact::from(ipinfo)).unwrap()
}

#[derive(Serialize)]
#[serde(rename = "ipxact:component")]
struct IPXact {
    // IP Overview
    #[serde(rename = "ipxact:vendor")]
    vendor: String,
    #[serde(rename = "ipxact:library")]
    library: String,
    #[serde(rename = "ipxact:user")]
    user: String,
    #[serde(rename = "ipxact:version")]
    version: String,
    #[serde(rename = "ipxact:description")]
    description: String,

    // BusInterfaces
    #[serde(rename = "ipxact:busInterfaces")]
    bus_interfaces: Vec<IPXActBusInterface>,

    // AddressSpace
    #[serde(rename = "ipxact:addressSpaces")]
    addr_spaces: Vec<IPXActAddrSpace>,

    // Model
    #[serde(rename = "ipxact:model")]
    model: IPXActModel,

    // FileSets
    #[serde(rename = "ipxact:fileSets")]
    file_sets: Vec<IPXActFileSet>,

    // Parameters
    #[serde(rename = "ipxact:parameters")]
    parameters: Vec<IPXActParameter>,
}

impl From<&IPInfo> for IPXact {
    fn from(ipinfo: &IPInfo) -> Self {
        IPXact {
            vendor: "Sasanqua Project".to_string(),
            library: "user".to_string(),
            user: ipinfo.name.clone(),
            version: ipinfo.version.clone(),
            description: "".to_string(),
            bus_interfaces: vec![],
            addr_spaces: vec![],
            model: IPXActModel::default(),
            file_sets: vec![],
            parameters: vec![],
        }
    }
}

#[derive(Serialize, Default)]
#[serde(rename = "ipxact:busInterface")]
struct IPXActBusInterface {}

#[derive(Serialize, Default)]
#[serde(rename = "ipxact:addressSpace")]
struct IPXActAddrSpace {}

#[derive(Serialize, Default)]
#[serde(rename = "ipxact:model")]
struct IPXActModel {}

#[derive(Serialize, Default)]
#[serde(rename = "ipxact:fileSet")]
struct IPXActFileSet {}

#[derive(Serialize, Default)]
#[serde(rename = "ipxact:parameter")]
struct IPXActParameter {}

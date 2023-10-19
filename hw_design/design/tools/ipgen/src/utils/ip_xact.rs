use serde::{Serialize, Deserialize};

use crate::IPInfo;

pub fn gen_ip_xact_xml(ipinfo: &IPInfo) -> String {
    quick_xml::se::to_string(&IPXact::from(ipinfo)).unwrap()
}

#[derive(Serialize)]
#[serde(rename = "component")]
struct IPXact {
    // IP Overview
    #[serde(rename = "vendor")]
    vendor: String,
    #[serde(rename = "library")]
    library: String,
    #[serde(rename = "user")]
    user: String,
    #[serde(rename = "version")]
    version: String,
    #[serde(rename = "description")]
    description: String,

    // BusInterfaces
    #[serde(rename = "busInterfaces")]
    bus_interfaces: Vec<IPXActBusInterface>,

    // AddressSpace
    #[serde(rename = "addressSpaces")]
    addr_spaces: Vec<IPXActAddrSpace>,

    // Model
    #[serde(rename = "model")]
    model: IPXActModel,

    // FileSets
    #[serde(rename = "fileSets")]
    file_sets: Vec<IPXActFileSet>,

    // Parameters
    #[serde(rename = "parameters")]
    parameters: Vec<IPXActParameter>,
}

impl<'a> From<&IPInfo> for IPXact {
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
#[serde(rename = "busInterface")]
struct IPXActBusInterface {}

#[derive(Serialize, Default)]
#[serde(rename = "addressSpace")]
struct IPXActAddrSpace {}

#[derive(Serialize, Default)]
#[serde(rename = "model")]
struct IPXActModel {}

#[derive(Serialize, Default)]
#[serde(rename = "fileSet")]
struct IPXActFileSet {}

#[derive(Debug, Serialize, Deserialize, Default)]
pub struct IPXActParameter {
    pub name: String,
    pub value: String,  // TODO: attributes
}

#[cfg(test)]
mod tests {
    use serde::{Serialize, Deserialize};

    use super::{IPXActParameter};

    #[test]
    fn de_parameters() {
        #[derive(Debug, Serialize, Deserialize)]
        #[serde(rename = "parameters")]
        struct Test {
            parameter: Vec<IPXActParameter>,
        }

        let sample = r#"
<?xml version="1.0" encoding="UTF-8"?>
<spirit:parameters>
    <spirit:parameter>
        <spirit:name>Component_Name</spirit:name>
        <spirit:value spirit:resolve="user" spirit:id="PARAM_VALUE.Component_Name" spirit:order="1">sasanqua_v1_0</spirit:value>
    </spirit:parameter>
    <spirit:parameter>
        <spirit:name>START_ADDR</spirit:name>
        <spirit:value spirit:format="bitString" spirit:resolve="user" spirit:id="PARAM_VALUE.START_ADDR" spirit:bitStringLength="32">0x00000000</spirit:value>
    </spirit:parameter>
</spirit:parameters>
        "#;

        check::<Test>(sample);
    }

    fn check<'a, T: Deserialize<'a>>(s: &'static str) {
        assert!(quick_xml::de::from_str::<T>(s).is_ok())
    }
}

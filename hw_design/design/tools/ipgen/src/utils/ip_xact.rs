use serde::{Serialize, Deserialize};

use crate::IPInfo;

pub fn gen_ip_xact_xml(ipinfo: &IPInfo) -> String {
    quick_xml::se::to_string(&IPXact::from(ipinfo)).unwrap()
}

#[derive(Serialize)]
#[serde(rename = "component", rename_all = "camelCase")]
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
    address_spaces: Vec<AddressSpace>,

    // Model
    #[serde(rename = "model")]
    model: IPXActModel,

    // FileSets
    file_sets: Vec<FileSet>,

    // Parameters
    parameters: Vec<Parameter>,
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
            address_spaces: vec![],
            model: IPXActModel::default(),
            file_sets: vec![],
            parameters: vec![],
        }
    }
}

#[derive(Serialize, Default)]
#[serde(rename = "busInterface")]
struct IPXActBusInterface {}

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct AddressSpace {
    pub name: String,
    pub display_name: String,
    pub range: String,
    pub width: u32,
}

#[derive(Serialize, Default)]
#[serde(rename = "model")]
struct IPXActModel {}

#[derive(Debug, Default, Serialize, Deserialize)]
pub struct FileSet {
    pub name: String,
    pub file: Vec<File>,
}

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct File {
    pub name: String,
    pub file_type: String,
}

#[derive(Debug, Default, Serialize, Deserialize)]
pub struct Parameter {
    pub name: String,
    pub value: String,  // TODO: attributes
}

#[cfg(test)]
mod tests {
    use std::fmt::Debug;

    use serde::{Serialize, Deserialize};

    use super::{AddressSpace, FileSet, Parameter};

    #[test]
    fn de_address_spaces() {
        let sample = r#"
            <?xml version="1.0" encoding="UTF-8"?>
            <spirit:addressSpaces>
                <spirit:addressSpace>
                    <spirit:name>M_AXI</spirit:name>
                    <spirit:displayName>M_AXI</spirit:displayName>
                    <spirit:range spirit:format="bitString" spirit:bitStringLength="33" spirit:minimum="4096" spirit:rangeType="long">0x100000000</spirit:range>
                    <spirit:width spirit:format="long">32</spirit:width>
                </spirit:addressSpace>
            </spirit:addressSpaces>
        "#;

        #[derive(Debug, Serialize, Deserialize)]
        #[serde(rename_all = "camelCase")]
        struct AddressSpaces {
            address_space: Vec<AddressSpace>,
        }

        check::<AddressSpaces>(sample);
    }

    #[test]
    fn de_file_sets() {
        let sample = r#"
            <?xml version="1.0" encoding="UTF-8"?>
            <spirit:fileSets>
                <spirit:fileSet>
                    <spirit:name>xilinx_verilogsynthesis_view_fileset</spirit:name>
                    <spirit:file>
                        <spirit:name>../../../../design/src/mem/axi/cache.v</spirit:name>
                        <spirit:fileType>verilogSource</spirit:fileType>
                    </spirit:file>
                    <spirit:file>
                        <spirit:name>../../../../design/src/core/components/pipeline/check.v</spirit:name>
                        <spirit:fileType>verilogSource</spirit:fileType>
                    </spirit:file>
                    <spirit:file>
                        <spirit:name>../../../../design/src/peripherals/clint.v</spirit:name>
                        <spirit:fileType>verilogSource</spirit:fileType>
                    </spirit:file>
                </spirit:fileSet>
                <spirit:fileSet>
                    <spirit:name>bd_tcl_view_fileset</spirit:name>
                    <spirit:file>
                        <spirit:name>bd/bd.tcl</spirit:name>
                        <spirit:fileType>tclSource</spirit:fileType>
                    </spirit:file>
                </spirit:fileSet>
            </spirit:fileSets>
        "#;

        #[derive(Debug, Serialize, Deserialize)]
        #[serde(rename_all = "camelCase")]
        struct FileSets {
            file_set: Vec<FileSet>,
        }

        check::<FileSets>(sample);
    }

    #[test]
    fn de_parameters() {
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

        #[derive(Debug, Serialize, Deserialize)]
        #[serde(rename_all = "camelCase")]
        struct Parameters {
            parameter: Vec<Parameter>,
        }

        check::<Parameters>(sample);
    }

    fn check<'a, T>(s: &'static str)
    where
        T: Deserialize<'a> + Debug,
    {
        let res = quick_xml::de::from_str::<T>(s);
        println!("{:?}", res);
        assert!(res.is_ok());
    }
}

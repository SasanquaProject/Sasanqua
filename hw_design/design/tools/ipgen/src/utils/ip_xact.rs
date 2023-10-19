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
    bus_interfaces: Vec<BusInterface>,

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

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct BusInterfaces {
    pub bus_interface: Vec<BusInterface>,
}

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct BusInterface {
    pub name: String,
    pub bus_type: (),
    pub abstraction_type: (),
    pub master: Option<()>,
    pub slave: Option<()>,
    pub port_maps: PortMaps,
    pub parameters: Option<Parameters>,
}

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PortMaps {
    pub port_map: Vec<PortMap>,
}

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PortMap {
    pub logical_port: LogicalPort,
    pub physical_port: PhysicalPort,
}

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LogicalPort {
    pub name: String,
}

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PhysicalPort {
    pub name: String,
}

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AddressSpaces {
    pub address_space: AddressSpace,
}

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AddressSpace {
    pub name: String,
    pub display_name: String,
    pub range: String,
    pub width: u32,
}

#[derive(Serialize, Default)]
#[serde(rename = "model")]
struct IPXActModel {}

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct FileSets {
    pub file_set: Vec<FileSet>,
}

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
pub struct Parameters {
    pub parameter: Vec<Parameter>,
}

#[derive(Debug, Default, Serialize, Deserialize)]
pub struct Parameter {
    pub name: String,
    pub value: String,  // TODO: attributes
}

#[cfg(test)]
mod tests {
    use std::fmt::Debug;

    use serde::Deserialize;

    use super::{BusInterfaces, AddressSpaces, FileSets, Parameters};

    #[test]
    fn de_bus_interfaces() {
        let sample = r#"
            <?xml version="1.0" encoding="UTF-8"?>
            <spirit:busInterfaces>
                <spirit:busInterface>
                    <spirit:name>RST</spirit:name>
                    <spirit:busType spirit:vendor="xilinx.com" spirit:library="signal" spirit:name="reset" spirit:version="1.0"/>
                    <spirit:abstractionType spirit:vendor="xilinx.com" spirit:library="signal" spirit:name="reset_rtl" spirit:version="1.0"/>
                    <spirit:slave/>
                    <spirit:portMaps>
                        <spirit:portMap>
                            <spirit:logicalPort>
                                <spirit:name>RST</spirit:name>
                            </spirit:logicalPort>
                            <spirit:physicalPort>
                                <spirit:name>RST</spirit:name>
                            </spirit:physicalPort>
                        </spirit:portMap>
                    </spirit:portMaps>
                </spirit:busInterface>
                <spirit:busInterface>
                    <spirit:name>CLK</spirit:name>
                    <spirit:busType spirit:vendor="xilinx.com" spirit:library="signal" spirit:name="clock" spirit:version="1.0"/>
                    <spirit:abstractionType spirit:vendor="xilinx.com" spirit:library="signal" spirit:name="clock_rtl" spirit:version="1.0"/>
                    <spirit:slave/>
                    <spirit:portMaps>
                        <spirit:portMap>
                            <spirit:logicalPort>
                                <spirit:name>CLK</spirit:name>
                            </spirit:logicalPort>
                            <spirit:physicalPort>
                                <spirit:name>CLK</spirit:name>
                            </spirit:physicalPort>
                        </spirit:portMap>
                    </spirit:portMaps>
                    <spirit:parameters>
                        <spirit:parameter>
                            <spirit:name>ASSOCIATED_RESET</spirit:name>
                            <spirit:value spirit:id="BUSIFPARAM_VALUE.CLK.ASSOCIATED_RESET">RST</spirit:value>
                        </spirit:parameter>
                        <spirit:parameter>
                            <spirit:name>ASSOCIATED_PORT</spirit:name>
                            <spirit:value spirit:id="BUSIFPARAM_VALUE.CLK.ASSOCIATED_PORT">STAT</spirit:value>
                        </spirit:parameter>
                        <spirit:parameter>
                            <spirit:name>ASSOCIATED_BUSIF</spirit:name>
                            <spirit:value spirit:id="BUSIFPARAM_VALUE.CLK.ASSOCIATED_BUSIF">M_AXI</spirit:value>
                        </spirit:parameter>
                    </spirit:parameters>
                </spirit:busInterface>
            </spirit:busInterfaces>
        "#;

        check::<BusInterfaces>(sample);
    }

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

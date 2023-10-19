use serde::{Deserialize, Serialize};

use super::parameter::Parameters;

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct BusInterfaces {
    bus_interface: Vec<BusInterface>,
}

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct BusInterface {
    name: String,
    bus_type: (),         // TODO: attributes
    abstraction_type: (), // TODO: attributes
    master: Option<()>,   // TODO: elements
    slave: Option<()>,
    port_maps: PortMaps,
    parameters: Option<Parameters>,
}

impl BusInterfaces {
    pub fn new() -> Self {
        BusInterfaces {
            bus_interface: vec![],
        }
    }

    pub fn add_master<S: Into<String>>(
        mut self,
        name: S,
        port_maps: PortMaps,
        parameters: Option<Parameters>,
    ) -> BusInterfaces {
        self.bus_interface.push(BusInterface {
            name: name.into(),
            bus_type: (),
            abstraction_type: (),
            master: Some(()),
            slave: None,
            port_maps: port_maps,
            parameters,
        });

        self
    }

    pub fn add_slave<S: Into<String>>(
        mut self,
        name: S,
        port_maps: PortMaps,
        parameters: Option<Parameters>,
    ) -> BusInterfaces {
        self.bus_interface.push(BusInterface {
            name: name.into(),
            bus_type: (),
            abstraction_type: (),
            master: None,
            slave: Some(()),
            port_maps: port_maps,
            parameters,
        });

        self
    }
}

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PortMaps {
    port_map: Vec<PortMap>,
}

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct PortMap {
    logical_port: LogicalPort,
    physical_port: PhysicalPort,
}

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct LogicalPort {
    name: String,
}

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct PhysicalPort {
    name: String,
}

impl PortMaps {
    pub fn new() -> Self {
        PortMaps { port_map: vec![] }
    }

    pub fn add_port_map<S: Into<String>>(mut self, logical_port: S, physical_port: S) -> Self {
        let logical_port = LogicalPort {
            name: logical_port.into(),
        };
        let physical_port = PhysicalPort {
            name: physical_port.into(),
        };

        self.port_map.push(PortMap {
            logical_port,
            physical_port,
        });

        self
    }
}

#[cfg(test)]
mod tests {
    use super::super::Parameters;
    use super::{BusInterfaces, PortMaps};

    #[test]
    fn serialize() {
        let port_maps_m = PortMaps::new()
            .add_port_map("AWLEN", "M_AXI_AWLEN")
            .add_port_map("AWREADY", "M_AXI_AWREADY");
        let port_maps_s = PortMaps::new().add_port_map("CLK", "CLK");
        let parameters_s = Parameters::new()
            .add_parameter("ASSOCIATED_RESET", "RST")
            .add_parameter("ASSOCIATED_BUSIF", "M_AXI");

        let bus_interfaces = BusInterfaces::new()
            .add_master("M_AXI", port_maps_m, None)
            .add_slave("CLK", port_maps_s, Some(parameters_s));

        assert!(quick_xml::se::to_string(&bus_interfaces).is_ok());
    }

    #[test]
    fn deserialize() {
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

        let res = quick_xml::de::from_str::<BusInterfaces>(sample);
        println!("{:?}", res);
        assert!(res.is_ok());
    }
}

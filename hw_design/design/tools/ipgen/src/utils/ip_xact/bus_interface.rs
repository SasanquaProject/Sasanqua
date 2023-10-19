use serde::{Serialize, Deserialize};

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
    bus_type: (), // TODO: attributes
    abstraction_type: (), // TODO: attributes
    master: Option<()>, // TODO: elements
    slave: Option<()>,
    port_maps: PortMaps,
    parameters: Option<Parameters>,
}

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct PortMaps {
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

#[cfg(test)]
mod tests {
    use super::BusInterfaces;

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

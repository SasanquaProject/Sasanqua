use serde::{Deserialize, Serialize};

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AddressSpaces {
    address_space: Vec<AddressSpace>,
}

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct AddressSpace {
    name: String,
    display_name: String,
    range: String,
    width: u32,
}

impl AddressSpaces {
    pub fn new() -> Self {
        AddressSpaces {
            address_space: vec![],
        }
    }

    pub fn add_address_space<S: Into<String>>(mut self, name: S, range: S, width: u32) -> Self {
        let name = name.into();
        let display_name = name.clone();
        let range = range.into();

        self.address_space.push(AddressSpace {
            name,
            display_name,
            range,
            width,
        });

        self
    }
}

#[cfg(test)]
mod tests {
    use super::AddressSpaces;

    #[test]
    fn serialize() {
        let address_spaces = AddressSpaces::new()
            .add_address_space("M_AXI", "0x100000000", 32)
            .add_address_space("M_AXI_2", "0x100000000", 32);

        assert!(quick_xml::se::to_string(&address_spaces).is_ok());
    }

    #[test]
    fn deserialize() {
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

        let res = quick_xml::de::from_str::<AddressSpaces>(sample);
        println!("{:?}", res);
        assert!(res.is_ok());
    }
}

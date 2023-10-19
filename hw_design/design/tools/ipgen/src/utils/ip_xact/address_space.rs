use serde::{Serialize, Deserialize};

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AddressSpaces {
    address_space: AddressSpace,
}

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct AddressSpace {
    name: String,
    display_name: String,
    range: String,
    width: u32,
}

#[cfg(test)]
mod tests {
    use super::AddressSpaces;

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

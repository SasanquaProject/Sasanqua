use serde::{Serialize, Deserialize};

#[derive(Debug, Default, Serialize, Deserialize)]
pub struct Parameters {
    parameter: Vec<Parameter>,
}

#[derive(Debug, Default, Serialize, Deserialize)]
struct Parameter {
    name: String,
    value: String,  // TODO: attributes
}

#[cfg(test)]
mod tests {
    use super::Parameters;

    #[test]
    fn deserialize() {
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

        let res = quick_xml::de::from_str::<Parameters>(sample);
        println!("{:?}", res);
        assert!(res.is_ok());
    }
}

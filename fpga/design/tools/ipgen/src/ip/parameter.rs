use serde::{Deserialize, Serialize};

#[derive(Debug, Default, Serialize, Deserialize)]
pub struct Parameters {
    parameter: Vec<Parameter>,
}

#[derive(Debug, Default, Serialize, Deserialize)]
struct Parameter {
    name: String,
    value: String, // TODO: attributes
}

impl Parameters {
    pub fn new() -> Self {
        Parameters { parameter: vec![] }
    }

    pub fn add_parameter<S: Into<String>>(mut self, name: S, value: S) -> Self {
        let name = name.into();
        let value = value.into();

        self.parameter.push(Parameter { name, value });

        self
    }
}

#[cfg(test)]
mod tests {
    use super::Parameters;

    #[test]
    fn serialize() {
        let parameters = Parameters::new()
            .add_parameter("AAA", "Hello")
            .add_parameter("BBB", "World");

        assert!(quick_xml::se::to_string(&parameters).is_ok());
    }

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

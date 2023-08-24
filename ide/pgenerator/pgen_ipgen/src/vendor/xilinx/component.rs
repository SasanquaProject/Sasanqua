use serde::Serialize;
use serde_xml_rs::to_string;

pub fn component_xml() -> String {
    let component = Component::default();
    Into::<String>::into(component)
}

#[derive(Serialize)]
#[serde(rename = "spirit:component")]
struct Component {
    // 固定値
    #[serde(rename = "spirit:vendor")]
    vendor: String,
    #[serde(rename = "spirit:library")]
    library: String,

    // ユーザ設定値
    #[serde(rename = "spirit:user")]
    user: String,
    #[serde(rename = "spirit:version")]
    version: String,

    // TODO: spirit:busInterfaces
    // TODO: spirit:addressSpaces
    // TODO: spirit:model
    // TODO: spirit:fileSets
    // TODO: spirit:description
    // TODO: spirit:parameters
    // TODO: spirit:vendorExtensions
}

impl Into<String> for Component {
    fn into(self) -> String {
        to_string(&self).unwrap()
    }
}

impl Default for Component {
    fn default() -> Self {
        Component {
            vendor: "YNakagami".to_string(),
            library: "user".to_string(),
            user: String::default(),
            version: String::default(),
        }
    }
}

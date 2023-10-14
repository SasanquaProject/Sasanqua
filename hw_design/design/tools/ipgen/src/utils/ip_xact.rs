use serde::Serialize;

use crate::IPInfo;

pub fn gen_ip_xact_xml(ipinfo: &IPInfo) -> String {
    serde_xml_rs::to_string(&IPXact::from(ipinfo)).unwrap()
}

#[derive(Serialize)]
#[serde(rename = "spirit:component")]
struct IPXact {
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

impl From<&IPInfo> for IPXact {
    fn from(_ipinfo: &IPInfo) -> Self {
        IPXact {
            vendor: "YNakagami".to_string(),
            library: "user".to_string(),
            user: String::default(),
            version: String::default(),
        }
    }
}

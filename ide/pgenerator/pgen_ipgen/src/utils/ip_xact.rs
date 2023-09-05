use serde::Serialize;

use hwgen::SasanquaT;
use hwgen::sasanqua::bus::BusInterface;

use crate::IPInfo;

pub fn gen_ip_xact_xml<S, B>(ipinfo: &IPInfo<S, B>) -> String
where
    S: SasanquaT<B>,
    B: BusInterface,
{
    serde_xml_rs::to_string(&Top::from(ipinfo)).unwrap()
}

#[derive(Serialize)]
#[serde(rename = "spirit:component")]
struct Top {
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

impl<S, B> From<&IPInfo<S, B>> for Top
where
    S: SasanquaT<B>,
    B: BusInterface,
{
    fn from(_ipinfo: &IPInfo<S, B>) -> Self {
        Top {
            vendor: "YNakagami".to_string(),
            library: "user".to_string(),
            user: String::default(),
            version: String::default(),
        }
    }
}

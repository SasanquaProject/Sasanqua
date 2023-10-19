use std::fs::read_to_string;

use clap::Parser;
use serde::{Deserialize, Serialize};
use thiserror::Error;

use coregen::gen_physfs;
use coregen::sasanqua::bus::AXI4;
use coregen::sasanqua::Sasanqua;
use ipgen::vendor::{Any, Xilinx};

#[derive(Debug, Parser)]
pub struct GenCmd {
    /// Configure file
    file: String,

    #[clap(short, default_value = "core_ip")]
    output: String,
}

impl GenCmd {
    pub fn run(&self) -> anyhow::Result<()> {
        let f = read_to_string(&self.file)?;
        let conf: IpConf = toml::from_str(&f)?;

        let sasanqua = match conf.core.bus_if.as_str() {
            "AXI4" => Sasanqua::new(AXI4),
            _ => {
                return Err(GenError::BusIFUnvalid(conf.core.bus_if).into());
            }
        };

        match conf.ip.vendor.as_str() {
            "Any" => gen_physfs::<Any, &str>(&sasanqua, &self.output)?,
            "Xilinx" => gen_physfs::<Xilinx, &str>(&sasanqua, &self.output)?,
            _ => return Err(GenError::VendorUnvalid(conf.ip.vendor).into()),
        };

        Ok(())
    }
}

#[derive(Debug, Serialize, Deserialize)]
pub(crate) struct IpConf {
    pub ip: IP,
    pub core: Core,
}

#[derive(Debug, Serialize, Deserialize)]
pub(crate) struct IP {
    pub name: String,
    pub version: String,
    pub vendor: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub(crate) struct Core {
    pub bus_if: String,
}

#[derive(Debug, Error)]
enum GenError {
    #[error("Specified bus-if '{0}' is not implemented.")]
    BusIFUnvalid(String),

    #[error("Specified vendor '{0}' is not implemented.")]
    VendorUnvalid(String),
}

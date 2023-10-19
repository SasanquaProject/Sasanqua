use std::fs::read_to_string;

use clap::Parser;
use serde::{Serialize, Deserialize};
use thiserror::Error;

use copgen::gen_physfs;
use copgen::pkg::CopPkg;
use std_cops::Rv32iMini;
use verilog_cops::Void;
use ipgen::vendor::{Any, Xilinx};

#[derive(Debug, Parser)]
pub struct GenCmd {
    /// Configure file
    file: String,

    #[clap(short, default_value = "cop_ip")]
    output: String,
}

impl GenCmd {
    pub fn run(&self) -> anyhow::Result<()> {
        let f = read_to_string(&self.file)?;
        let conf: IpConf = toml::from_str(&f)?;

        let mut cop_pkg = CopPkg::new(&conf.ip.name, &conf.ip.name);
        for cop_profile in conf.profile {
            cop_pkg = match cop_profile.name.as_str() {
                "rv32i_mini" => cop_pkg.add_cop(Rv32iMini),
                "void" => cop_pkg.add_cop(Void),
                _ => { return Err(GenError::CopImplUnvalid(cop_profile.name).into()) },
            };
        }

        match conf.ip.vendor.as_str() {
            "Any" => gen_physfs::<Any, &str>(cop_pkg, &self.output)?,
            "Xilinx" => gen_physfs::<Xilinx, &str>(cop_pkg, &self.output)?,
            _ => return Err(GenError::VendorUnvalid(conf.ip.vendor).into()),
        };

        Ok(())
    }
}

#[derive(Debug, Serialize, Deserialize)]
pub(crate) struct IpConf {
    pub ip: IP,
    pub profile: Vec<Cop>,
}

#[derive(Debug, Serialize, Deserialize)]
pub(crate) struct IP {
    pub name: String,
    pub version: String,
    pub vendor: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub(crate) struct Cop {
    pub name: String,
}

#[derive(Debug, Error)]
enum GenError {
    #[error("Specified cop-impl '{0}' is not implemented.")]
    CopImplUnvalid(String),

    #[error("Specified vendor '{0}' is not implemented.")]
    VendorUnvalid(String),
}

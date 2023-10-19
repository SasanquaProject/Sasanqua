use std::fs::File;
use std::io::Write;

use clap::Parser;

use super::gen::{Cop, IpConf, IP};

#[derive(Debug, Parser)]
pub struct NewCmd {
    #[clap(short, default_value = "cop.toml")]
    output: String,
}

impl NewCmd {
    pub fn run(&self) -> anyhow::Result<()> {
        let ip = IP {
            name: "core".to_string(),
            version: "0.1.0".to_string(),
            vendor: "Any".to_string(),
        };
        let profile = vec![
            Cop {
                name: "rv32i_mini".to_string(),
            },
            Cop {
                name: "void".to_string(),
            },
        ];
        let ip_conf = IpConf { ip, profile };
        let ip_conf = toml::to_string(&ip_conf)?;

        let mut f = File::create(&self.output)?;
        f.write_all(ip_conf.as_bytes())?;
        f.flush()?;

        Ok(())
    }
}

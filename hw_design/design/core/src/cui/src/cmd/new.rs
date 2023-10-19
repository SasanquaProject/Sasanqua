use std::fs::File;
use std::io::Write;

use clap::Parser;

use super::gen::{IpConf, IP, Core};

#[derive(Debug, Parser)]
pub struct NewCmd {
    #[clap(short, default_value = "core.toml")]
    output: String,
}

impl NewCmd {
    pub fn run(&self) -> anyhow::Result<()> {
        let ip = IP {
            name: "core".to_string(),
            version: "0.1.0".to_string()
        };
        let core = Core {
            bus_if: "AXI4".to_string(),
            vendor: "Any".to_string(),
        };
        let ip_conf = IpConf { ip, core };
        let ip_conf = toml::to_string(&ip_conf)?;

        let mut f = File::create(&self.output)?;
        f.write_all(ip_conf.as_bytes())?;
        f.flush()?;

        Ok(())
    }
}

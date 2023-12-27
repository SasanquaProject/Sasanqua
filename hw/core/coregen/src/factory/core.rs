use vfs::VfsPath;

use super::HwMakable;
use crate::Sasanqua;

pub struct CoreFactory;

impl HwMakable for CoreFactory {
    fn make(_: &Sasanqua, root: &mut VfsPath) -> anyhow::Result<()> {
        // core
        root.join("core")?.create_dir()?;

        root.join("core/core.v")?
            .create_file()?
            .write_all(include_bytes!("../../hw_parts/core/core.v"))?;

        // core/components
        root.join("core/components")?.create_dir()?;

        root.join("core/components/main.v")?
            .create_file()?
            .write_all(include_bytes!("../../hw_parts/core/components/main.v"))?;

        root.join("core/components/mmu.v")?
            .create_file()?
            .write_all(include_bytes!("../../hw_parts/core/components/mmu.v"))?;

        // core/components/pipeline
        root.join("core/components/pipeline")?.create_dir()?;

        root.join("core/components/pipeline/check.v")?
            .create_file()?
            .write_all(include_bytes!(
                "../../hw_parts/core/components/pipeline/check.v"
            ))?;

        root.join("core/components/pipeline/cushion.v")?
            .create_file()?
            .write_all(include_bytes!(
                "../../hw_parts/core/components/pipeline/cushion.v"
            ))?;

        root.join("core/components/pipeline/decode.v")?
            .create_file()?
            .write_all(include_bytes!(
                "../../hw_parts/core/components/pipeline/decode.v"
            ))?;

        root.join("core/components/pipeline/exec.v")?
            .create_file()?
            .write_all(include_bytes!(
                "../../hw_parts/core/components/pipeline/exec.v"
            ))?;

        root.join("core/components/pipeline/fectch.v")?
            .create_file()?
            .write_all(include_bytes!(
                "../../hw_parts/core/components/pipeline/fetch.v"
            ))?;

        root.join("core/components/pipeline/mread.v")?
            .create_file()?
            .write_all(include_bytes!(
                "../../hw_parts/core/components/pipeline/mread.v"
            ))?;

        root.join("core/components/pipeline/pool.v")?
            .create_file()?
            .write_all(include_bytes!(
                "../../hw_parts/core/components/pipeline/pool.v"
            ))?;

        root.join("core/components/pipeline/schedule.v")?
            .create_file()?
            .write_all(include_bytes!(
                "../../hw_parts/core/components/pipeline/schedule.v"
            ))?;

        root.join("core/components/pipeline/trap.v")?
            .create_file()?
            .write_all(include_bytes!(
                "../../hw_parts/core/components/pipeline/trap.v"
            ))?;

        // core/components/pipeline/register
        root.join("core/components/pipeline/register")?
            .create_dir()?;

        root.join("core/components/pipeline/register/std_csr.v")?
            .create_file()?
            .write_all(include_bytes!(
                "../../hw_parts/core/components/pipeline/register/std_csr.v"
            ))?;

        root.join("core/components/pipeline/register/std_rv32i.v")?
            .create_file()?
            .write_all(include_bytes!(
                "../../hw_parts/core/components/pipeline/register/std_rv32i.v"
            ))?;

        Ok(())
    }
}
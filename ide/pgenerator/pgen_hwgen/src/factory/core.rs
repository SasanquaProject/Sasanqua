use vfs::VfsPath;

use super::HwFactory;
use crate::resources::*;
use crate::sasanqua::Sasanqua;
use crate::sasanqua::bus::AXI4;

pub struct CoreFactory;

impl HwFactory<AXI4> for CoreFactory {
    fn gen(_: &Sasanqua<AXI4>, root: &mut VfsPath) -> anyhow::Result<()> {
        // core
        root.join("core")?.create_dir()?;

        root.join("core/core.v")?
            .create_file()?
            .write_all(CORE_CORE_V.as_bytes())?;

        // core/pipeline
        root.join("core/pipeline")?.create_dir()?;

        root.join("core/pipeline/check.v")?
            .create_file()?
            .write_all(CORE_PIPELINE_CHECK_V.as_bytes())?;

        root.join("core/pipeline/cushion.v")?
            .create_file()?
            .write_all(CORE_PIPELINE_CUSHION_V.as_bytes())?;

        root.join("core/pipeline/decode.v")?
            .create_file()?
            .write_all(CORE_PIPELINE_DECODE_V.as_bytes())?;

        root.join("core/pipeline/fetch.v")?
            .create_file()?
            .write_all(CORE_PIPELINE_FETCH_V.as_bytes())?;

        root.join("core/pipeline/mread.v")?
            .create_file()?
            .write_all(CORE_PIPELINE_MREAD_V.as_bytes())?;

        root.join("core/pipeline/schedule_1st.v")?
            .create_file()?
            .write_all(CORE_PIPELINE_SCHEDULE_1ST_V.as_bytes())?;

        // core/pipeline/exec
        root.join("core/pipeline/exec")?.create_dir()?;

        root.join("core/pipeline/exec/std_rv32i_s.v")?
            .create_file()?
            .write_all(CORE_PIPELINE_EXEC_STD_RV32I_S_V.as_bytes())?;

        // core/pipeline/register
        root.join("core/pipeline/register")?.create_dir()?;

        root.join("core/pipeline/register/std_csr.v")?
            .create_file()?
            .write_all(CORE_PIPELINE_REGISTER_STD_CSR_V.as_bytes())?;

        root.join("core/pipeline/register/std_rv32i.v")?
            .create_file()?
            .write_all(CORE_PIPELINE_REGISTER_STD_RV32I_V.as_bytes())?;

        Ok(())
    }
}

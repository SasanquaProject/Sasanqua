// sasanqua.v
pub const SASANQUA_V: &'static str = include_str!("../../../../hw_design/design/src/sasanqua.v");

// core
pub const CORE_CORE_V: &'static str = include_str!("../../../../hw_design/design/src/core/core.v");

// core/pipeline
pub const CORE_PIPELINE_CHECK_V: &'static str = include_str!("../../../../hw_design/design/src/core/pipeline/check.v");
pub const CORE_PIPELINE_CUSHION_V: &'static str = include_str!("../../../../hw_design/design/src/core/pipeline/cushion.v");
pub const CORE_PIPELINE_DECODE_V: &'static str = include_str!("../../../../hw_design/design/src/core/pipeline/decode.v");
pub const CORE_PIPELINE_FETCH_V: &'static str = include_str!("../../../../hw_design/design/src/core/pipeline/fetch.v");
pub const CORE_PIPELINE_MREAD_V: &'static str = include_str!("../../../../hw_design/design/src/core/pipeline/mread.v");
pub const CORE_PIPELINE_SCHEDULE_1ST_V: &'static str = include_str!("../../../../hw_design/design/src/core/pipeline/schedule_1st.v");

// core/pipeline/exec
pub const CORE_PIPELINE_EXEC_STD_RV32I_S_V: &'static str = include_str!("../../../../hw_design/design/src/core/pipeline/exec/std_rv32i_s.v");

// core/pipeline/register
pub const CORE_PIPELINE_REGISTER_STD_CSR_V: &'static str = include_str!("../../../../hw_design/design/src/core/pipeline/register/std_csr.v");
pub const CORE_PIPELINE_REGISTER_STD_RV32I_V: &'static str = include_str!("../../../../hw_design/design/src/core/pipeline/register/std_rv32i.v");

// mmu/axi
pub const MMU_AXI_CACHE_V: &'static str = include_str!("../../../../hw_design/design/src/mmu/axi/cache.v");
pub const MMU_AXI_INTERCONNECT_V: &'static str = include_str!("../../../../hw_design/design/src/mmu/axi/interconnect.v");
pub const MMU_AXI_MMU_V: &'static str = include_str!("../../../../hw_design/design/src/mmu/axi/mmu.v");
pub const MMU_AXI_TRANSLATE_V: &'static str = include_str!("../../../../hw_design/design/src/mmu/axi/translate.v");

// mmu/utils/ram
pub const MMU_UTILS_RAM_DUALPORT_V: &'static str = include_str!("../../../../hw_design/design/src/mmu/utils/ram/ram_dualport.v");
pub const MMU_UTILS_ROM_DUALPORT_V: &'static str = include_str!("../../../../hw_design/design/src/mmu/utils/rom/rom_dualport.v");

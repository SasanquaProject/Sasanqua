use vfs::VfsPath;

use crate::IPInfo;
use crate::vendor::Vendor;

pub struct Xilinx;

impl Vendor for Xilinx {
    fn gen(_: &IPInfo, root: &mut VfsPath) -> anyhow::Result<()> {
        // TODO: component.xml

        root.join("xgui")?
            .create_dir()?;
        root.join("xgui/xgui.tcl")?
            .create_file()?
            .write_all(xgui_tcl().as_bytes())?;

        root.join("bd")?
            .create_dir()?;
        root.join("bd/bd.tcl")?
            .create_file()?
            .write_all(bd_tcl().as_bytes())?;

        Ok(())
    }
}

fn xgui_tcl() -> &'static str {
    r##"
proc init_gui { IPINST } {
    ipgui::add_param $IPINST -name "Component_Name"
    ipgui::add_param $IPINST -name "START_ADDR"
    ipgui::add_page $IPINST -name "Page 0"
}

proc update_PARAM_VALUE.START_ADDR { PARAM_VALUE.START_ADDR } {

}

proc validate_PARAM_VALUE.START_ADDR { PARAM_VALUE.START_ADDR } {
	return true
}

proc update_MODELPARAM_VALUE.START_ADDR { MODELPARAM_VALUE.START_ADDR PARAM_VALUE.START_ADDR } {
	set_property value [get_property value ${PARAM_VALUE.START_ADDR}] ${MODELPARAM_VALUE.START_ADDR}
}
    "##
}

fn bd_tcl() -> &'static str {
    r##"
proc init { cellpath otherInfo } {
	set cell_handle [get_bd_cells $cellpath]
	set all_busif [get_bd_intf_pins $cellpath/*]
	set axi_standard_param_list [list ID_WIDTH AWUSER_WIDTH ARUSER_WIDTH WUSER_WIDTH RUSER_WIDTH BUSER_WIDTH]
	set full_sbusif_list [list  ]

	foreach busif $all_busif {
		if { [string equal -nocase [get_property MODE $busif] "slave"] == 1 } {
			set busif_param_list [list]
			set busif_name [get_property NAME $busif]
			if { [lsearch -exact -nocase $full_sbusif_list $busif_name ] == -1 } {
			    continue
			}
			foreach tparam $axi_standard_param_list {
				lappend busif_param_list "C_${busif_name}_${tparam}"
			}
			bd::mark_propagate_only $cell_handle $busif_param_list
		}
	}
}

proc pre_propagate { cellpath otherInfo } {
	set cell_handle [get_bd_cells $cellpath]
	set all_busif [get_bd_intf_pins $cellpath/*]
	set axi_standard_param_list [list ID_WIDTH AWUSER_WIDTH ARUSER_WIDTH WUSER_WIDTH RUSER_WIDTH BUSER_WIDTH]

	foreach busif $all_busif {
		if { [string equal -nocase [get_property CONFIG.PROTOCOL $busif] "AXI4"] != 1 } {
			continue
		}
		if { [string equal -nocase [get_property MODE $busif] "master"] != 1 } {
			continue
		}

		set busif_name [get_property NAME $busif]
		foreach tparam $axi_standard_param_list {
			set busif_param_name "C_${busif_name}_${tparam}"

			set val_on_cell_intf_pin [get_property CONFIG.${tparam} $busif]
			set val_on_cell [get_property CONFIG.${busif_param_name} $cell_handle]

			if { [string equal -nocase $val_on_cell_intf_pin $val_on_cell] != 1 } {
				if { $val_on_cell != "" } {
					set_property CONFIG.${tparam} $val_on_cell $busif
				}
			}
		}
	}
}

proc propagate { cellpath otherInfo } {
	set cell_handle [get_bd_cells $cellpath]
	set all_busif [get_bd_intf_pins $cellpath/*]
	set axi_standard_param_list [list ID_WIDTH AWUSER_WIDTH ARUSER_WIDTH WUSER_WIDTH RUSER_WIDTH BUSER_WIDTH]

	foreach busif $all_busif {
		if { [string equal -nocase [get_property CONFIG.PROTOCOL $busif] "AXI4"] != 1 } {
			continue
		}
		if { [string equal -nocase [get_property MODE $busif] "slave"] != 1 } {
			continue
		}

		set busif_name [get_property NAME $busif]
		foreach tparam $axi_standard_param_list {
			set busif_param_name "C_${busif_name}_${tparam}"

			set val_on_cell_intf_pin [get_property CONFIG.${tparam} $busif]
			set val_on_cell [get_property CONFIG.${busif_param_name} $cell_handle]

			if { [string equal -nocase $val_on_cell_intf_pin $val_on_cell] != 1 } {
				if { $val_on_cell_intf_pin != "" } {
					set_property CONFIG.${busif_param_name} $val_on_cell_intf_pin $cell_handle
				}
			}
		}
	}
}
    "##
}

#[cfg(test)]
mod test {
    use vfs::{VfsPath, MemoryFS};

    use crate::IPInfo;
    use super::Xilinx;

    #[test]
    fn check_req_files() {
        let mut root = MemoryFS::new().into();
        IPInfo::new("test", "0.1.0").gen::<Xilinx>(&mut root).unwrap();

        assert!(open_file(&root, "component.xml").is_ok());
        assert!(open_file(&root, "xgui/xgui.tcl").is_ok());
        assert!(open_file(&root, "bd/bd.tcl").is_ok());
    }

    fn open_file(root: &VfsPath, path: &str) -> anyhow::Result<VfsPath> {
        let f = root.join(path).unwrap();
        assert!(f.exists()?);
        Ok(f)
    }
}

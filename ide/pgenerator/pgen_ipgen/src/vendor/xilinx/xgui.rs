pub const XGUI_TCL: &[u8] =
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
"##.as_bytes();

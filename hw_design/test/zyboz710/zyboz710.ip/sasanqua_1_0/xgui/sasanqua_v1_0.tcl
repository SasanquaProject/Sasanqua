# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  ipgui::add_param $IPINST -name "START_ADDR"
  #Adding Page
  ipgui::add_page $IPINST -name "Page 0"


}

proc update_PARAM_VALUE.START_ADDR { PARAM_VALUE.START_ADDR } {
	# Procedure called to update START_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.START_ADDR { PARAM_VALUE.START_ADDR } {
	# Procedure called to validate START_ADDR
	return true
}


proc update_MODELPARAM_VALUE.START_ADDR { MODELPARAM_VALUE.START_ADDR PARAM_VALUE.START_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.START_ADDR}] ${MODELPARAM_VALUE.START_ADDR}
}


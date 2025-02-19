# TCL File Generated by Component Editor 18.1
# Sat Nov 27 00:17:09 CET 2021
# DO NOT MODIFY


# 
# RealTimeClock "RealTimeClock" v1.0
# Chen 2021.11.27.00:17:09
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module RealTimeClock
# 
set_module_property DESCRIPTION ""
set_module_property NAME RealTimeClock
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "My Components"
set_module_property AUTHOR Chen
set_module_property DISPLAY_NAME RealTimeClock
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL RealTimeClock
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file RealTimeClock.vhd VHDL PATH ../hdl/LED/RealTimeClock.vhd
add_fileset_file bin_to_bcd.vhd VHDL PATH ../hdl/LED/bin_to_bcd.vhd
add_fileset_file clk_divider.vhd VHDL PATH ../hdl/LED/clk_divider.vhd
add_fileset_file counter_control.vhd VHDL PATH ../hdl/LED/counter_control.vhd
add_fileset_file decode_seg.vhd VHDL PATH ../hdl/LED/decode_seg.vhd
add_fileset_file display_control.vhd VHDL PATH ../hdl/LED/display_control.vhd

add_fileset SIM_VERILOG SIM_VERILOG "" ""
set_fileset_property SIM_VERILOG TOP_LEVEL RealTimeClock
set_fileset_property SIM_VERILOG ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property SIM_VERILOG ENABLE_FILE_OVERWRITE_MODE true
add_fileset_file RealTimeClock.vhd VHDL PATH ../hdl/LED/RealTimeClock.vhd
add_fileset_file bin_to_bcd.vhd VHDL PATH ../hdl/LED/bin_to_bcd.vhd
add_fileset_file clk_divider.vhd VHDL PATH ../hdl/LED/clk_divider.vhd
add_fileset_file counter_control.vhd VHDL PATH ../hdl/LED/counter_control.vhd
add_fileset_file decode_seg.vhd VHDL PATH ../hdl/LED/decode_seg.vhd
add_fileset_file display_control.vhd VHDL PATH ../hdl/LED/display_control.vhd


# 
# parameters
# 


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point avalon_slave_0
# 
add_interface avalon_slave_0 avalon end
set_interface_property avalon_slave_0 addressUnits WORDS
set_interface_property avalon_slave_0 associatedClock clock
set_interface_property avalon_slave_0 associatedReset reset_sink
set_interface_property avalon_slave_0 bitsPerSymbol 8
set_interface_property avalon_slave_0 burstOnBurstBoundariesOnly false
set_interface_property avalon_slave_0 burstcountUnits WORDS
set_interface_property avalon_slave_0 explicitAddressSpan 0
set_interface_property avalon_slave_0 holdTime 0
set_interface_property avalon_slave_0 linewrapBursts false
set_interface_property avalon_slave_0 maximumPendingReadTransactions 0
set_interface_property avalon_slave_0 maximumPendingWriteTransactions 0
set_interface_property avalon_slave_0 readLatency 0
set_interface_property avalon_slave_0 readWaitTime 1
set_interface_property avalon_slave_0 setupTime 0
set_interface_property avalon_slave_0 timingUnits Cycles
set_interface_property avalon_slave_0 writeWaitTime 0
set_interface_property avalon_slave_0 ENABLED true
set_interface_property avalon_slave_0 EXPORT_OF ""
set_interface_property avalon_slave_0 PORT_NAME_MAP ""
set_interface_property avalon_slave_0 CMSIS_SVD_VARIABLES ""
set_interface_property avalon_slave_0 SVD_ADDRESS_GROUP ""

add_interface_port avalon_slave_0 address address Input 3
add_interface_port avalon_slave_0 write write Input 1
add_interface_port avalon_slave_0 read read Input 1
add_interface_port avalon_slave_0 writedata writedata Input 8
add_interface_port avalon_slave_0 readdata readdata Output 8
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isFlash 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isPrintableDevice 0


# 
# connection point reset_sink
# 
add_interface reset_sink reset end
set_interface_property reset_sink associatedClock clock
set_interface_property reset_sink synchronousEdges DEASSERT
set_interface_property reset_sink ENABLED true
set_interface_property reset_sink EXPORT_OF ""
set_interface_property reset_sink PORT_NAME_MAP ""
set_interface_property reset_sink CMSIS_SVD_VARIABLES ""
set_interface_property reset_sink SVD_ADDRESS_GROUP ""

add_interface_port reset_sink nReset reset_n Input 1


# 
# connection point conduit_SelSeg
# 
add_interface conduit_SelSeg conduit end
set_interface_property conduit_SelSeg associatedClock clock
set_interface_property conduit_SelSeg associatedReset reset_sink
set_interface_property conduit_SelSeg ENABLED true
set_interface_property conduit_SelSeg EXPORT_OF ""
set_interface_property conduit_SelSeg PORT_NAME_MAP ""
set_interface_property conduit_SelSeg CMSIS_SVD_VARIABLES ""
set_interface_property conduit_SelSeg SVD_ADDRESS_GROUP ""

add_interface_port conduit_SelSeg SelSeg export Output 8


# 
# connection point conduit_SelDig
# 
add_interface conduit_SelDig conduit end
set_interface_property conduit_SelDig associatedClock clock
set_interface_property conduit_SelDig associatedReset reset_sink
set_interface_property conduit_SelDig ENABLED true
set_interface_property conduit_SelDig EXPORT_OF ""
set_interface_property conduit_SelDig PORT_NAME_MAP ""
set_interface_property conduit_SelDig CMSIS_SVD_VARIABLES ""
set_interface_property conduit_SelDig SVD_ADDRESS_GROUP ""

add_interface_port conduit_SelDig nSelDig export Output 6


# 
# connection point conduit_ResetLed
# 
add_interface conduit_ResetLed conduit end
set_interface_property conduit_ResetLed associatedClock clock
set_interface_property conduit_ResetLed associatedReset reset_sink
set_interface_property conduit_ResetLed ENABLED true
set_interface_property conduit_ResetLed EXPORT_OF ""
set_interface_property conduit_ResetLed PORT_NAME_MAP ""
set_interface_property conduit_ResetLed CMSIS_SVD_VARIABLES ""
set_interface_property conduit_ResetLed SVD_ADDRESS_GROUP ""

add_interface_port conduit_ResetLed Reset_Led export Output 1


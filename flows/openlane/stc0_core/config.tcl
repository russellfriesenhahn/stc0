set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) stc0_core

set ::env(VERILOG_FILES) "\
    [glob $script_dir/../../../verilog/rtl/*.v]"

set ::env(CLOCK_PORT) "ClkIngress"
set ::env(CLOCK_NET) "ClkIngress"
set ::env(CLOCK_PERIOD) "10"

#set ::env(FP_SIZING) absolute
#set ::env(DIE_AREA) "0 0 900 600"
set ::env(DESIGN_IS_CORE) 0

set ::env(VDD_NETS) [list {vccd1} {vccd2} {vdda1} {vdda2}]
set ::env(GND_NETS) [list {vssd1} {vssd2} {vssa1} {vssa2}]
#set ::env(VDD_NETS) [list {vccd1} {vccd2}]
#set ::env(GND_NETS) [list {vssd1} {vssd2}]

set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

set ::env(GLB_RT_MAXLAYER) 5
set ::env(SYNTH_STRATEGY) "DELAY 0"
set ::env(FP_CORE_UTIL) 30
set ::env(PL_BASIC_PLACEMENT) 0
set ::env(PL_TARGET_DENSITY) 0.4
set ::env(CELL_PAD) 2
set ::env(GLB_RT_ADJUSTMENT) 0.2

set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 4
set ::env(DIODE_INSERTION_STRATEGY) 3

# If you're going to use multiple power domains, then keep this disabled.
set ::env(RUN_CVC) 1

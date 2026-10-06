
########################### Define Top Module ############################
                                                   
set top_module SYS_TOP

######################### Formality Setup File ###########################

set synopsys_auto_setup true

set_svf "../../DFT/$top_module.svf"


set SSLIB "/home/ICer/tsmc_fb_cl013g_sc/aci/sc-m/synopsys/scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db"
set TTLIB "/home/ICer/tsmc_fb_cl013g_sc/aci/sc-m/synopsys/scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db"
set FFLIB "/home/ICer/tsmc_fb_cl013g_sc/aci/sc-m/synopsys/scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db"

######################### Reference Container ############################

## Read Reference technology libraries

read_db -container Ref [list $SSLIB $TTLIB $FFLIB]

## Read Reference Design Files

read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/MUX.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/TOP.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/TOP_RX.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/TOP_TX.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/ALU_FUN.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/FIFO_RD.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/FIFO_WR.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/RegFile.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/RST_SYN.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/CLK_GATE.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/Sync_r2w.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/Sync_w2r.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/TOP_UART.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/PULSE_GEN.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/CLKDIV_MUX.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/Serializer.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/Stop_check.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/Strt_Check.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/CLK_Divider.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/FIFO_Memory.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/Parity_Calc.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/A_System_Top.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/deserializer.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/Parity_Check.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/data_sampling.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/edge_pit_counter.v"
read_verilog -container Ref  "/home/ICer/Projects/System/ALL_RTL/Data_Synchronizer.v"

read_sverilog -container Ref "/home/ICer/Projects/System/ALL_RTL/FSM_RX.sv"
read_sverilog -container Ref "/home/ICer/Projects/System/ALL_RTL/FSM_TX.sv"
read_sverilog -container Ref "/home/ICer/Projects/System/ALL_RTL/SYS_CTRL.sv"

## set the top Reference Design 

set_reference_design SYS_TOP
set_top SYS_TOP

######################## Implementation Container #########################

## Read Implementation technology libraries

read_db -container Imp [list $SSLIB $TTLIB $FFLIB]

## Read Implementation Design Files

read_verilog -container Imp "/home/ICer/Projects/System/System_pnr/pnr/export/SYS_TOP.v"
 
## set the top Implementation Design

set_implementation_design SYS_TOP
set_top SYS_TOP

############################### Don't verify #################################

#scan_out
set_dont_verify_points -type port Imp:/WORK/*/SO[0]
set_dont_verify_points -type port Imp:/WORK/*/SO[1]
set_dont_verify_points -type port Imp:/WORK/*/SO[2]
set_dont_verify_points -type port Imp:/WORK/*/SO[3]

#scan_in
set_dont_verify_points -type port Imp:/WORK/*/SI[0]
set_dont_verify_points -type port Imp:/WORK/*/SI[1]
set_dont_verify_points -type port Imp:/WORK/*/SI[2]
set_dont_verify_points -type port Imp:/WORK/*/SI[3]


############################### constants #####################################

#test_mode
set_constant -type port Imp:/WORK/*/test_mode 0

#scan_enable
set_constant -type port Imp:/WORK/*/SE 0


########################### matching Compare points ##########################

match

################################# verify #####################################

set successful [verify]
if {!$successful} {
diagnose
analyze_points -failing
}

report_passing_points    > "reports/passing_points.rpt"
report_failing_points    > "reports/failing_points.rpt"
report_aborted_points    > "reports/aborted_points.rpt"
report_unverified_points > "reports/unverified_points.rpt"


start_gui

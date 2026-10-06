set_app_var power_enable_analysis true
set_app_var power_analysis_mode time_based
set power_vcd_time_unit 1ns

set report_dir report
file mkdir $report_dir

set Out_report Sys_pw
#------------------------------------------------------------------------------
# Libraries
#------------------------------------------------------------------------------
lappend search_path /home/ICer/tsmc_fb_cl013g_sc/aci/sc-m/synopsys

set TTLIB   scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db
set SSLIB   scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db
set FFLIB   scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db

set target_library [list $TTLIB $SSLIB $FFLIB]
set link_library   [list * $TTLIB $SSLIB $FFLIB]

#------------------------------------------------------------------------------
# Read Design Files
#------------------------------------------------------------------------------

# Read Verilog Netlist
read_verilog ../PNR_Results/SYS_TOP.v

current_design SYS_TOP

link_design

# Read SDC File
read_sdc ../PNR_Results/SYS_TOP.sdc

# Read SDF File
read_sdf ../PNR_Results/SYS_TOP.sdf

#------------------------------------------------------------------------------
# Read Switching Activity
#------------------------------------------------------------------------------
read_vcd -strip_path tb_SYS_TOP/DUT ../sim/VCD/SYS_TOP.vcd

update_power

#------------------------------------------------------------------------------
# Report Power
#------------------------------------------------------------------------------
report_power                              > $report_dir/$Out_report.rpt

echo "----------------------------------------"
echo "PrimeTime PX Analysis Finished"
echo "Reports saved in:"
echo "$report_dir"
echo "----------------------------------------"

#------------------------------------------------------------------------------
# Timing Analysis
#------------------------------------------------------------------------------
update_timing

# Setup Violations Only
report_timing -delay_type max \
              -slack_lesser_than 0 \
              -max_paths 100 \
              > $report_dir/setup_violations.rpt

# Hold Violations Only
report_timing -delay_type min \
              -slack_lesser_than 0 \
              -max_paths 100 \
              > $report_dir/hold_violations.rpt

# Worst 100 Setup Paths INCLUDING POSITIVE SLACK
report_timing -delay_type max \
              -slack_lesser_than 1000000 \
              -max_paths 100 \
              > $report_dir/setup_worst100.rpt

# Worst 100 Hold Paths INCLUDING POSITIVE SLACK
report_timing -delay_type min \
              -slack_lesser_than 1000000 \
              -max_paths 100 \
              > $report_dir/hold_worst100.rpt

#start_gui
exit

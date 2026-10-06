
####################################################################################
# Constraints
# ----------------------------------------------------------------------------
#
# 0. Design Compiler variables
#
# 1. Master Clock Definitions
#
# 2. Generated Clock Definitions
#
# 3. Clock Uncertainties
#
# 4. Clock Latencies 
#
# 5. Clock Relationships
#
# 6. #set input/output delay on ports
#
# 7. Driving cells
#
# 8. Output load

####################################################################################
           #########################################################
                  #### Section 0 : DC Variables ####
           #########################################################
#################################################################################### 

# Prevent assign statements in the generated netlist (must be applied before compile command)
set_fix_multiple_port_nets -all -buffer_constants -feedthroughs

####################################################################################
           #########################################################
                  #### Section 1 : Clock Definition ####
           #########################################################
#################################################################################### 
# 1. Master Clock Definitions 
# 2. Generated Clock Definitions
# 3. Clock Latencies
# 4. Clock Uncertainties
# 4. Clock Transitions
####################################################################################

set REF_CLK_NAME       REF_CLK
set REF_CLK_PER        20
set REF_CLK_SETUP_SKEW 0.2
set REF_CLK_HOLD_SKEW  0.1
set REF_CLK_LAT        0
set REF_CLK_RISE       0.05
set REF_CLK_FALL       0.05

set UART_CLK_NAME       UART_CLK
set UART_CLK_PER        271.26736
set UART_CLK_SETUP_SKEW 0.2
set UART_CLK_HOLD_SKEW  0.1
set UART_CLK_LAT        0
set UART_CLK_RISE       0.05
set UART_CLK_FALL       0.05

#1. Master Clocks

#REF_CLK
create_clock -name $REF_CLK_NAME -period $REF_CLK_PER -waveform "0 [expr $REF_CLK_PER/2]" [get_ports REF_CLK]
set_clock_uncertainty -setup $REF_CLK_SETUP_SKEW  [get_clocks $REF_CLK_NAME]
set_clock_uncertainty -hold  $REF_CLK_HOLD_SKEW   [get_clocks $REF_CLK_NAME]
set_clock_transition  -rise  $REF_CLK_RISE        [get_clocks $REF_CLK_NAME]
set_clock_transition  -fall  $REF_CLK_FALL        [get_clocks $REF_CLK_NAME]
set_clock_latency            $REF_CLK_LAT         [get_clocks $REF_CLK_NAME]
#UART_CLK
create_clock -name $UART_CLK_NAME -period $UART_CLK_PER -waveform "0 [expr $UART_CLK_PER/2]" [get_ports UART_CLK]
set_clock_uncertainty -setup $UART_CLK_SETUP_SKEW [get_clocks $UART_CLK_NAME]
set_clock_uncertainty -hold  $UART_CLK_HOLD_SKEW  [get_clocks $UART_CLK_NAME]
set_clock_transition  -rise  $UART_CLK_RISE       [get_clocks $UART_CLK_NAME]
set_clock_transition  -fall  $UART_CLK_FALL       [get_clocks $UART_CLK_NAME]
set_clock_latency            $UART_CLK_LAT        [get_clocks $UART_CLK_NAME]

#2. Generated clocks

#UART_TX_CLK
create_generated_clock -master_clock $UART_CLK_NAME -source [get_ports UART_CLK] \
                       -name "UART_TX_CLK" [get_pins UO_TX_ClkDiv/o_div_clk] \
                       -divide_by 32
set_clock_uncertainty -setup $UART_CLK_SETUP_SKEW [get_clocks UART_TX_CLK]
set_clock_uncertainty -hold $UART_CLK_HOLD_SKEW   [get_clocks UART_TX_CLK]
#UART_RX_CLK
create_generated_clock -master_clock $UART_CLK_NAME -source [get_ports UART_CLK] \
                       -name "UART_RX_CLK" [get_pins UO_RX_ClkDiv/o_div_clk] \
                       -divide_by 1
set_clock_uncertainty -setup $UART_CLK_SETUP_SKEW [get_clocks UART_RX_CLK]
set_clock_uncertainty -hold $UART_CLK_HOLD_SKEW   [get_clocks UART_RX_CLK]
#CLK_GATE
create_generated_clock -master_clock $REF_CLK_NAME -source [get_ports REF_CLK] \
                       -name "GATED_CLK" [get_pins UO_CLK_GATE/GATED_CLK] \
                       -divide_by 1
set_clock_uncertainty -setup $REF_CLK_SETUP_SKEW [get_clocks GATED_CLK]
set_clock_uncertainty -hold $REF_CLK_HOLD_SKEW   [get_clocks GATED_CLK]

#################################### SCAN Clocks ###################################
set DFT_CLK_NAME DFTCLK
set DFT_CLK_PER 100
set DFT_CLK_SETUP_SKEW 0.2
set DFT_CLK_HOLD_SKEW 0.1
set DFT_CLK_LAT 0
set DFT_CLK_RISE 0.05
set DFT_CLK_FALL 0.05

create_clock -name $DFT_CLK_NAME -period $DFT_CLK_PER -waveform "0 [expr $DFT_CLK_PER/2]" [get_ports scan_clk]
set_clock_uncertainty -setup $DFT_CLK_SETUP_SKEW [get_clocks $DFT_CLK_NAME]
set_clock_uncertainty -hold $DFT_CLK_HOLD_SKEW  [get_clocks $DFT_CLK_NAME]
set_clock_transition -rise $DFT_CLK_RISE  [get_clocks $DFT_CLK_NAME]
set_clock_transition -fall $DFT_CLK_FALL  [get_clocks $DFT_CLK_NAME]
set_clock_latency $DFT_CLK_LAT [get_clocks $DFT_CLK_NAME]


set_dont_touch_network "$REF_CLK_NAME $UART_CLK_NAME $DFT_CLK_NAME UART_TX_CLK UART_RX_CLK GATED_CLK"


####################################################################################
           #########################################################
             #### Section 2 : Clocks Relationship ####
           #########################################################
####################################################################################

set_clock_groups -logically_exclusive -group [get_clocks "REF_CLK GATED_CLK"]     \
                                      -group [get_clocks "$DFT_CLK_NAME"]

set_clock_groups -logically_exclusive -group [get_clocks "UART_CLK UART_TX_CLK UART_RX_CLK"]     \
                                      -group [get_clocks "$DFT_CLK_NAME"]

set_clock_groups -asynchronous \
    -group [get_clocks {REF_CLK GATED_CLK}] \
    -group [get_clocks {UART_CLK UART_TX_CLK UART_RX_CLK}]

####################################################################################
           #########################################################
             #### Section 3 : #set input/output delay on ports ####
           #########################################################
####################################################################################

set UART_RX_CLK_PER [expr $UART_CLK_PER*1]
set UART_TX_CLK_PER [expr $UART_CLK_PER*32]

set in_delay     [expr 0.2*$UART_RX_CLK_PER]
set tx_out_delay [expr 0.2*$UART_TX_CLK_PER]
set rx_out_delay [expr 0.2*$UART_RX_CLK_PER]

set DFT_IO_DELAY [expr 0.2*$DFT_CLK_PER]

#Constrain Input Paths
set_input_delay $in_delay      -clock UART_RX_CLK [get_ports UART_RX_IN]
#Constrain Scan Input Paths
set_input_delay  $DFT_IO_DELAY -clock DFTCLK      [get_ports SI]
set_input_delay  $DFT_IO_DELAY -clock DFTCLK      [get_ports SE]
#Constrain Scan Output Paths
set_output_delay $DFT_IO_DELAY -clock DFTCLK      [get_ports SO]
#Constrain Output Paths
set_output_delay $tx_out_delay -clock UART_TX_CLK [get_ports UART_TX_O]
set_output_delay $rx_out_delay -clock UART_RX_CLK [get_ports parity_error]
set_output_delay $rx_out_delay -clock UART_RX_CLK [get_ports framing_error]

####################################################################################
           #########################################################
                  #### Section 4 : Driving cells ####
           #########################################################
####################################################################################

set_driving_cell -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -lib_cell BUFX2M -pin Y [get_ports UART_RX_IN]
set_driving_cell -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -lib_cell BUFX2M -pin Y [get_ports SI]
set_driving_cell -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -lib_cell BUFX2M -pin Y [get_ports SE]

####################################################################################
           #########################################################
                  #### Section 5 : Output load ####
           #########################################################
####################################################################################

set_load 0.1 [get_ports UART_TX_O]
set_load 0.1 [get_ports parity_error]
set_load 0.1 [get_ports framing_error]
#scan ports
set_load 0.1 [get_ports SO]

####################################################################################
           #########################################################
                 #### Section 6 : Operating Condition ####
           #########################################################
####################################################################################

# Define the Worst Library for Max(#setup) analysis
# Define the Best Library for Min(hold) analysis

set_operating_conditions -min_library "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" -min "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" -max_library "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c" -max "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c"

####################################################################################
           #########################################################
                  #### Section 7 : wireload Model ####
           #########################################################
####################################################################################


####################################################################################
           #########################################################
                  #### Section 8 : premapped cells ####
           #########################################################
####################################################################################

set_dont_touch [get_designs CLK_GATE]

####################################################################################
           #########################################################
                  #### Section 8 : Case Analysis ####
           #########################################################
####################################################################################

#set_case_analysis 1 [get_ports test_mode]

####################################################################################



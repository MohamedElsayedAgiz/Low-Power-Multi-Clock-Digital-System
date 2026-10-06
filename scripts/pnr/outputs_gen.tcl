
#===========================================================
# Timing Reports
#===========================================================

# Setup Report
report_timing -late -max_paths 100 > reports/setup.rpt

# Hold Report
report_timing -early -max_paths 100 > reports/hold.rpt

# Setup / Max timing
timeDesign -postRoute -outDir reports/setup_final

# Hold / Min timing
timeDesign -postRoute -hold -outDir reports/hold_final


#===========================================================
# Power Report
#===========================================================

report_power -outfile reports/power.rpt


#===========================================================
# Physical Verification Reports
#===========================================================

# Geometry / DRC Check
verifyGeometry -report reports/geometry.rpt

# Connectivity Check
verifyConnectivity -type all -error 1000 -warning 50 -report reports/connectivity.rpt

# Antenna Check
verifyProcessAntenna -reportfile reports/antenna.rpt -error 1000

#===========================================================
#===========================================================


########### Reports & Netlist & GDS Generation ############

set top_module SYS_TOP

# Generate Post-PNR Gate Level Netlist
saveNetlist export/${top_module}.v 

# Generate Post-PNR Gate Level Netlist with PG Pins
saveNetlist export/${top_module}_pg.v -includePowerGround

# SPF File standard for defining netlist parasitics.
rcOut -spf export/${top_module}.spf

# Generate SDF File
delayCal -sdf export/${top_module}.sdf -version 3.0

# Generate SDC File
write_sdc export/${top_module}.sdc

# Generate GDS File
streamOut export/${top_module}.gds -mapFile ./import/gds2InLayer.map -libName DesignLib -stripes 1 -units 2000 -mode ALL


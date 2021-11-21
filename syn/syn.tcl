# design_vision script for the synthesis

# Variables
# Increment version as you do new synthesis to avoid overwriting old reports
variable version $SYN_VERSION

# Analyze the VHDL files from the src folder
analyze -f vhdl -lib WORK ../src/$ENTITY_NAME.vhd
# Preserve rtl names to ease the procedure for power consumption estimation
set power_preserve_rtl_hier_names true
# Elaborate the architecture
elaborate $ENTITY_NAME -lib WORK
uniquify
link

# Set constraints
# Create a clock whose period is set in the variable at the beginning of this document
create_clock -name MY_CLK -period $PERIOD CLK
report_clock > reports/clock_report_$version.txt
set_dont_touch_network MY_CLK
# Set clock uncertainty
set_clock_uncertainty 0.07 [get_clocks MY_CLK]
set_input_delay 0.5 -max -clock MY_CLK [remove_from_collection [all_inputs] CLK]
set_output_delay 0.5 -max -clock MY_CLK [all_outputs]
set OLOAD [load_of NangateOpenCellLibrary/BUF_X4/A]
set_load $OLOAD [all_outputs]

# Synthesize
compile

# Print reports
report_timing -delay max > reports/timing_report_setup_$version.txt
report_timing -delay min > reports/timing_report_hold_$version.txt
report_area > reports/area_report_$version.txt
report_power > reports/power_report_noswitching_$version.txt


# Save files for switching-activity-based power estimation
ungroup -all -flatten
change_names -hierarchy -rules verilog
write_sdf ../netlist/$ENTITY_NAME.sdf
write -f verilog -hierarchy -output ../netlist/$ENTITY_NAME.v
write_sdc ../netlist/$ENTITY_NAME.sdc

quit

#RISC-V LITE - design_vision script for the synthesis

# Analyze the VHDL files from the src folder
analyze -f vhdl -lib WORK ../src/$VERSION_FOLDER/components/adder.vhd
analyze -f vhdl -lib WORK ../src/$VERSION_FOLDER/components/alu.vhd
analyze -f vhdl -lib WORK ../src/$VERSION_FOLDER/components/comparator.vhd
analyze -f vhdl -lib WORK ../src/$VERSION_FOLDER/components/control.vhd
analyze -f vhdl -lib WORK ../src/$VERSION_FOLDER/components/forwarding_unit.vhd
analyze -f vhdl -lib WORK ../src/$VERSION_FOLDER/components/hazard_mux.vhd
analyze -f vhdl -lib WORK ../src/$VERSION_FOLDER/components/HDU.vhd
analyze -f vhdl -lib WORK ../src/$VERSION_FOLDER/components/immediate_generator.vhd
analyze -f vhdl -lib WORK ../src/$VERSION_FOLDER/components/register_file.vhd
analyze -f vhdl -lib WORK ../src/$VERSION_FOLDER/fetch_stage.vhd
analyze -f vhdl -lib WORK ../src/$VERSION_FOLDER/decode_stage.vhd
analyze -f vhdl -lib WORK ../src/$VERSION_FOLDER/execute_stage.vhd
analyze -f vhdl -lib WORK ../src/$VERSION_FOLDER/memory_stage.vhd
analyze -f vhdl -lib WORK ../src/$VERSION_FOLDER/writeback_stage.vhd
analyze -f vhdl -lib WORK ../src/$VERSION_FOLDER/$ENTITY_NAME.vhd
# Preserve rtl names to ease the procedure for power consumption estimation
set power_preserve_rtl_hier_names true
# Elaborate the architecture
elaborate $ENTITY_NAME -lib WORK
uniquify
link

# Set constraints
# Create a clock whose period is set in the variable at the beginning of this document
create_clock -name MY_CLK -period $PERIOD clk
report_clock > reports/clock_report_$SYNTHESIS_NAME.txt
set_dont_touch_network MY_CLK
# Set clock uncertainty
set_clock_uncertainty 0.07 [get_clocks MY_CLK]
set_input_delay 0.5 -max -clock MY_CLK [remove_from_collection [all_inputs] clk]
set_output_delay 0.5 -max -clock MY_CLK [all_outputs]
set OLOAD [load_of NangateOpenCellLibrary/BUF_X4/A]
set_load $OLOAD [all_outputs]

# Synthesize
compile

# Print reports
report_timing -delay max > reports/timing_report_setup_$SYNTHESIS_NAME.txt
report_timing -delay min > reports/timing_report_hold_$SYNTHESIS_NAME.txt
report_area > reports/area_report_$SYNTHESIS_NAME.txt
report_power > reports/power_report_noswitching_$SYNTHESIS_NAME.txt


# Save files for switching-activity-based power estimation
ungroup -all -flatten
change_names -hierarchy -rules verilog
write_sdf ../netlist/$VERSION_FOLDER/$ENTITY_NAME.sdf
write -f verilog -hierarchy -output ../netlist/$VERSION_FOLDER/$ENTITY_NAME.v
write_sdc ../netlist/$VERSION_FOLDER/$ENTITY_NAME.sdc

quit

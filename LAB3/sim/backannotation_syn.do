# Backannotation Modelsim script (for Synopsis netlist)
# This script is executed and used to record the switching activity of the nodes
# in the generated netlist.

# Compile VHDL and Verilog files
vcom -93 -work ./work ../tb/clk_gen.vhd
vcom -93 -work ./work ../tb/instruction_memory.vhd
vcom -93 -work ./work ../tb/data_memory.vhd
vlog -work ./work ../netlist/$VERSION_FOLDER/$ENTITY_NAME.v
vlog -work ./work ../tb/$TB_NAME.v

# Include the functional model of the cells in the technology library
vsim -L /software/dk/nangate45/verilog/msim6.2g work.$TB_NAME

# Link the delay file (.sdf file)
vsim -L /software/dk/nangate45/verilog/msim6.2g -sdftyp /$TB_NAME/DUT=../netlist/$VERSION_FOLDER/$ENTITY_NAME.sdf work.$TB_NAME

# Create VCD file (value-change-dump: records switching activity)
vcd file ../vcd/$VERSION_FOLDER/$ENTITY_NAME.vcd

# Add all signals / monitor all signals and dump their activity into vcd file
vcd add /$TB_NAME/DUT/*

# Run the simulation
run $SIM_TIME

quit -sim
quit

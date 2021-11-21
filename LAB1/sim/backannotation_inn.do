echo "Compiling vhdl files..."

vcom -93 -work ./work ../src/$ENTITY_NAME.vhd
vcom -93 -work ./work ../tb/clk_gen.vhd
vcom -93 -work ./work ../tb/data_gen.vhd
vcom -93 -work ./work ../tb/data_gen_lookahead.vhd
vcom -93 -work ./work ../tb/data_save.vhd

echo "Compiling verilog files..."

vlog -work ./work ../tb/$TB_NAME.v
vlog -work ./work ../netlist/${ENTITY_NAME}_inn.v

echo "Including the functional model of the cells..."

vsim -L /software/dk/nangate45/verilog/msim6.2g work.$TB_NAME

echo "Linking the delay file (.sdf file)..."

vsim -L /software/dk/nangate45/verilog/msim6.2g -sdftyp /$TB_NAME/DUT=../innovus/$ENTITY_NAME.sdf work.$TB_NAME

#opening the .vcd file
vcd file ../vcd/${ENTITY_NAME}_inn.vcd

#monitor all the signals of our DUT
vcd add /$TB_NAME/DUT/*

#running the simulation
run $SIM_TIME

#quit modelsim
quit -sim
quit 

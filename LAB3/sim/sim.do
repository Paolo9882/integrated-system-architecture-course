#RISC-V LITE - Modelsim simulation script

#compile source files basic version
vcom -93 -work ./work ../src/$VERSION_FOLDER/components/adder.vhd
vcom -93 -work ./work ../src/$VERSION_FOLDER/components/alu.vhd
vcom -93 -work ./work ../src/$VERSION_FOLDER/components/comparator.vhd
vcom -93 -work ./work ../src/$VERSION_FOLDER/components/control.vhd
vcom -93 -work ./work ../src/$VERSION_FOLDER/components/forwarding_unit.vhd
vcom -93 -work ./work ../src/$VERSION_FOLDER/components/hazard_mux.vhd
vcom -93 -work ./work ../src/$VERSION_FOLDER/components/HDU.vhd
vcom -93 -work ./work ../src/$VERSION_FOLDER/components/immediate_generator.vhd
vcom -93 -work ./work ../src/$VERSION_FOLDER/components/register_file.vhd
vcom -93 -work ./work ../src/$VERSION_FOLDER/fetch_stage.vhd
vcom -93 -work ./work ../src/$VERSION_FOLDER/decode_stage.vhd
vcom -93 -work ./work ../src/$VERSION_FOLDER/execute_stage.vhd
vcom -93 -work ./work ../src/$VERSION_FOLDER/memory_stage.vhd
vcom -93 -work ./work ../src/$VERSION_FOLDER/writeback_stage.vhd
vcom -93 -work ./work ../src/$VERSION_FOLDER/$ENTITY_NAME.vhd

#compile test-bench
vcom -93 -work ./work ../tb/clk_gen.vhd
vcom -93 -work ./work ../tb/instruction_memory.vhd
vcom -93 -work ./work ../tb/data_memory.vhd
vlog -work ./work ../tb/$TB_NAME.v

#simulate
vsim work.$TB_NAME
run $SIM_TIME

#quit modelsim
quit -sim
quit







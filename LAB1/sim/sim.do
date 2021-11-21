#IIR filter - Modelsim simulation script

#compile source files
vcom -93 -work ./work ../src/$ENTITY_NAME.vhd

#compile test-bench
vcom -93 -work ./work ../tb/clk_gen.vhd
vcom -93 -work ./work ../tb/data_gen.vhd
vcom -93 -work ./work ../tb/data_gen_lookahead.vhd
vcom -93 -work ./work ../tb/data_save.vhd
vlog -work ./work ../tb/$TB_NAME.v

#simulate
vsim work.$TB_NAME
run $SIM_TIME

#quit modelsim
quit -sim
quit 






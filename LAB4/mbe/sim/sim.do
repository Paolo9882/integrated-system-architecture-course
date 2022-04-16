#UVM - Questasim simulation script

#compile source files
vcom -93 -work ./work ../src/bru.vhd
vcom -93 -work ./work ../src/half_adder.vhd
vcom -93 -work ./work ../src/full_adder.vhd
vcom -93 -work ./work ../src/dadda_tree.vhd
vcom -93 -work ./work ../src/pp_generation.vhd
vcom -93 -work ./work ../src/mbe_mult.vhd

#compile test-bench
vlog -sv ../tb/$TB_NAME.sv

#simulate
vsim $TB_NAME
run $SIM_TIME

#quit questasim
quit -sim
quit







#UVM - Questasim simulation script

#compile source files
vcom -93 -work ./work ../src/bru.vhd
vcom -93 -work ./work ../src/half_adder.vhd
vcom -93 -work ./work ../src/full_adder.vhd
vcom -93 -work ./work ../src/dadda_tree.vhd
vcom -93 -work ./work ../src/pp_generation.vhd
vcom -93 -work ./work ../src/mbe_mult.vhd
vcom -93 -work ./work ../src/fpnormalize_fpnormalize.vhd
vcom -93 -work ./work ../src/fpround_fpround.vhd
vcom -93 -work ./work ../src/packfp_packfp.vhd
vcom -93 -work ./work ../src/unpackfp_unpackfp.vhd
vcom -93 -work ./work ../src/fpmul_stage1_struct.vhd
vcom -93 -work ./work ../src/fpmul_stage2_struct.vhd
vcom -93 -work ./work ../src/fpmul_stage3_struct.vhd
vcom -93 -work ./work ../src/fpmul_stage4_struct.vhd
vcom -93 -work ./work ../src/FPmul.vhd

#compile test-bench
vlog -sv ../tb/$TB_NAME.sv

#simulate
vsim $TB_NAME
run $SIM_TIME

#quit questasim
quit -sim
quit







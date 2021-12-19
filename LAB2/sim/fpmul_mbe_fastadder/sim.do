#FPmul using MBE - Modelsim simulation script

#compile source files

vcom -93 -work ./work ../../src/fpmul_mbe_fastadder/half_adder.vhd
vcom -93 -work ./work ../../src/fpmul_mbe_fastadder/full_adder.vhd
vcom -93 -work ./work ../../src/fpmul_mbe_fastadder/bru.vhd
vcom -93 -work ./work ../../src/fpmul_mbe_fastadder/pp_generation.vhd
vcom -93 -work ./work ../../src/fpmul_mbe_fastadder/dadda_tree.vhd
vcom -93 -work ./work ../../src/fpmul_mbe_fastadder/mbe_mult.vhd

vcom -93 -work ./work ../../src/common/fpnormalize_fpnormalize.vhd
vcom -93 -work ./work ../../src/common/fpround_fpround.vhd
vcom -93 -work ./work ../../src/common/packfp_packfp.vhd
vcom -93 -work ./work ../../src/common/unpackfp_unpackfp.vhd

vcom -93 -work ./work ../../src/fpmul_mbe_fastadder/fpmul_stage1_struct.vhd
vcom -93 -work ./work ../../src/fpmul_mbe_fastadder/fpmul_stage2_struct.vhd
vcom -93 -work ./work ../../src/fpmul_mbe_fastadder/fpmul_stage3_struct.vhd
vcom -93 -work ./work ../../src/fpmul_mbe_fastadder/fpmul_stage4_struct.vhd
vcom -93 -work ./work ../../src/fpmul_mbe_fastadder/FPmul.vhd

#compile test-bench
vcom -93 -work ./work ../../tb/clk_gen.vhd
vcom -93 -work ./work ../../tb/data_maker.vhd
vcom -93 -work ./work ../../tb/data_save.vhd
vlog -work ./work ../../tb/$TB_NAME.v

#simulate
vsim work.$TB_NAME
run $SIM_TIME

#quit modelsim
quit -sim
quit 






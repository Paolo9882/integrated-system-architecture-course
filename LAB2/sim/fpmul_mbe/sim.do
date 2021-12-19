#FPmul using MBE - Modelsim simulation script

#compile source files

vcom -93 -work ./work ../../src/fpmul_mbe/half_adder.vhd
vcom -93 -work ./work ../../src/fpmul_mbe/full_adder.vhd
vcom -93 -work ./work ../../src/fpmul_mbe/bru.vhd
vcom -93 -work ./work ../../src/fpmul_mbe/rca.vhd
vcom -93 -work ./work ../../src/fpmul_mbe/pp_generation.vhd
vcom -93 -work ./work ../../src/fpmul_mbe/dadda_tree.vhd
vcom -93 -work ./work ../../src/fpmul_mbe/mbe_mult.vhd

vcom -93 -work ./work ../../src/common/fpnormalize_fpnormalize.vhd
vcom -93 -work ./work ../../src/common/fpround_fpround.vhd
vcom -93 -work ./work ../../src/common/packfp_packfp.vhd
vcom -93 -work ./work ../../src/common/unpackfp_unpackfp.vhd

vcom -93 -work ./work ../../src/fpmul_mbe/fpmul_stage1_struct.vhd
vcom -93 -work ./work ../../src/fpmul_mbe/fpmul_stage2_struct.vhd
vcom -93 -work ./work ../../src/fpmul_mbe/fpmul_stage3_struct.vhd
vcom -93 -work ./work ../../src/fpmul_mbe/fpmul_stage4_struct.vhd
vcom -93 -work ./work ../../src/fpmul_mbe/FPmul.vhd

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






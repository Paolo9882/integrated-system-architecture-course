#FPmul with input registers - Modelsim simulation script

#compile source files

vcom -93 -work ./work ../../src/common/fpnormalize_fpnormalize.vhd
vcom -93 -work ./work ../../src/common/fpround_fpround.vhd
vcom -93 -work ./work ../../src/common/packfp_packfp.vhd
vcom -93 -work ./work ../../src/common/unpackfp_unpackfp.vhd

vcom -93 -work ./work ../../src/fpmul_pipeline/fpmul_stage1_struct.vhd
vcom -93 -work ./work ../../src/fpmul_pipeline/fpmul_stage2_struct.vhd
vcom -93 -work ./work ../../src/fpmul_pipeline/fpmul_stage3_struct.vhd
vcom -93 -work ./work ../../src/fpmul_pipeline/fpmul_stage4_struct.vhd
vcom -93 -work ./work ../../src/fpmul_pipeline/FPmul.vhd

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






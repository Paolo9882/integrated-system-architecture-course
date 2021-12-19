#FPmul with input registers and a pipeline level in stage 2 - Modelsim simulation script

#In this version, a level of register was put at the end of stage 2 in order to compile
#with the retiming functionality of Synopsys' DC (this allows for fine-grain of the significand
#multiplier and therefore to increase the performance of the floating-point multiplier)

#compile source files

vcom -93 -work ./work ../../src/common/fpnormalize_fpnormalize.vhd
vcom -93 -work ./work ../../src/common/fpround_fpround.vhd
vcom -93 -work ./work ../../src/common/packfp_packfp.vhd
vcom -93 -work ./work ../../src/common/unpackfp_unpackfp.vhd

vcom -93 -work ./work ../../src/fpmul_pipeline_finegrain/fpmul_stage1_struct.vhd
vcom -93 -work ./work ../../src/fpmul_pipeline_finegrain/fpmul_stage2_struct.vhd
vcom -93 -work ./work ../../src/fpmul_pipeline_finegrain/fpmul_stage3_struct.vhd
vcom -93 -work ./work ../../src/fpmul_pipeline_finegrain/fpmul_stage4_struct.vhd
vcom -93 -work ./work ../../src/fpmul_pipeline_finegrain/FPmul.vhd

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






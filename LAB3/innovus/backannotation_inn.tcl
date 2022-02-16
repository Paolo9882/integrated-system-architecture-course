#Innovus place & route script (backannotation)

variable ENTITY_NAME riscv_lite
variable VERSION_FOLDER pro_version

set_global _enable_mmmc_by_default_flow      $CTE::mmmc_default
suppressMessage ENCEXT-2799
getDrawView
loadWorkspace -name Physical
win
encMessage warning 0
encMessage debug 0
encMessage info 0
restoreDesign ./$ENTITY_NAME.enc.dat $ENTITY_NAME
setDrawView fplan
encMessage warning 1
encMessage debug 0
encMessage info 1
reset_parasitics
extractRC
rcOut -setload ${ENTITY_NAME}_backanno.setload -rc_corner my_rc
rcOut -setres ${ENTITY_NAME}_backanno.setres -rc_corner my_rc
rcOut -spf ${ENTITY_NAME}_backanno.spf -rc_corner my_rc
rcOut -spef ${ENTITY_NAME}_backanno.spef -rc_corner my_rc
set_power_analysis_mode -reset
set_power_analysis_mode -method static -corner max -create_binary_db true -write_static_currents true -honor_negative_energy true -ignore_control_signals true
set_power_output_dir -reset
set_power_output_dir ./
set_default_switching_activity -reset
set_default_switching_activity -input_activity 0.2 -period 10.0
read_activity_file -reset
read_activity_file -format VCD -scope tb_$ENTITY_NAME/DUT -start {} -end {} -block {} ../vcd/$VERSION_FOLDER/${ENTITY_NAME}_inn.vcd
set_power -reset
set_powerup_analysis -reset
set_dynamic_power_simulation -reset
report_power -rail_analysis_format VS -outfile .//$ENTITY_NAME.rpt
report_power -outfile powerReports/$VERSION_FOLDER/$ENTITY_NAME -clock_network all -hierarchy all -power_domain all -pg_net all -net -sort { total }
exit

#UVM - Questasim simulation script

#compile test-bench
vlog -sv ../tb/$TB_NAME.sv

#simulate
vsim $TB_NAME
run $SIM_TIME

#quit questasim
quit -sim
quit







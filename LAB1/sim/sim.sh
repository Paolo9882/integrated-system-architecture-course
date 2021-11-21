#!/bin/bash

#Simulation parameters

#Change here ("" or "_lookahead")
VERSION=""

#Variables (do not change them)
ENTITY_NAME="iir_2nd_order$VERSION"
TB_NAME="tb_iir_2nd_order$VERSION"
C_FILE="results_c$VERSION.txt"
VHD_FILE="results_tb.txt"
SIM_TIME="10us"

echo "Automation for the ModelSim workflow"
echo "--- START ---"

#Initialize Modelsim environment
echo "[*] Initialization of Modelsim environment"
source /software/scripts/init_msim6.2g > log_sim.txt

#Delete the previous working directory and create a new one
if [ -d ./work ]
	then
	rm -r ./work
fi
vlib work

#Set variables and run simulation script on modelsim
echo "[*] Modelsim is running..."
vsim -c -do "set ENTITY_NAME $ENTITY_NAME; set TB_NAME $TB_NAME; set SIM_TIME $SIM_TIME; do sim.do" >> log_sim.txt

#Check the results
echo "[*] Checking results..."
python3 checker.py $C_FILE $VHD_FILE

#Rename the files to avoid overwriting when the checker will be invoked with the synthesis netlist
mv results_tb.txt results_vhd$VERSION.txt
mv log_check.txt log_check_presyn.txt

echo "--- END ---"

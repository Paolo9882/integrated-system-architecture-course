#!/bin/bash

#Simulation parameters

#Change here with "" or "_MBE"
VERSION=""

INPUT_FOLDER="fpmul_pipeline"

#Variables (do not change them)
ENTITY_NAME="FPmul$VERSION"
TB_NAME="tb_FPmul$VERSION"
REF_FILE="fp_prod.hex"
VHD_FILE="results_tb.hex"
SIM_TIME="10us"

echo "Automation for the ModelSim workflow"
echo "--- START ---"
echo "Which folder would you like to simulate?"
read -p "> " INPUT_FOLDER

cd $INPUT_FOLDER
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

cd ..

#Check the results
echo "[*] Checking results..."
python3 checker.py $REF_FILE $INPUT_FOLDER/$VHD_FILE

echo "--- END ---"

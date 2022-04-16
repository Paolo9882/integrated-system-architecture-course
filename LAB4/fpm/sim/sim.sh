#!/bin/bash

#Simulation parameters
TB_NAME="top"
SIM_TIME="4us"
OPTION="$1"

echo "Automation for the QuestaSim workflow"
echo "--- START ---"

#Initialize Questasim environment
echo "[*] Initialization of QuestaSim environment"
source /software/scripts/init_questa10.7c > log/log_sim.txt

#Delete the previous working directory and create a new one
if [ -d ./work ]
	then
	rm -r ./work
fi
vlib work

#Set variables and run simulation script on modelsim
echo "[*] QuestaSim is running..."
if [ "$OPTION" = "-gui" ] 
then
	vsim -do "set TB_NAME $TB_NAME; set SIM_TIME $SIM_TIME; do sim.do"
else
	vsim -c -do "set TB_NAME $TB_NAME; set SIM_TIME $SIM_TIME; do sim.do" >> log/log_sim.txt

	#Show results on terminal
	echo "############################"
	tail -n 17 log/log_sim.txt | head -n 13
	echo "############################"
fi



echo "--- END ---"

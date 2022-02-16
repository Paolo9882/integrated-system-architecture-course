#!/bin/bash

#Simulation parameters

#Change here ("" or "_pro")
VERSION=""
VERSION_FOLDER=""
PROGRAM_SOURCE="../material/minv-rv.s"

#Variables (do not change them)
ENTITY_NAME="riscv_lite"
TB_NAME="tb_riscv_lite"
REF_FILE="data_memory_ref.txt"
OUT_FILE="data_memory_dump.txt"
IM_SIZE="256"
SIM_TIME="1.250us"

#If there is one argument from the command line, then assemble the file
#that is passed as the first argument (./sim.sh ../material/algo.s)
if [[ $# -eq 1 ]]
    then
    PROGRAM_SOURCE=$1
fi

#If there are two arguments from the command line, then the source of the program
#is the first paramater while the second parameter sets VERSION to "_pro"
if [[ $# -eq 2 ]]
	then
	PROGRAM_SOURCE=$1
	VERSION="_pro"
fi

#Depending on the version "basic" or "pro", pass this parameter to ModelSim to 
#compile the files in the correct path (/src/basic_version/... or /src/pro_version/...)
if [[ -z $VERSION ]]; then
	VERSION_FOLDER="basic_version"
else
	VERSION_FOLDER="pro_version"
fi

echo "Automation for the ModelSim workflow"
echo "PROGRAM SOURCE: ${PROGRAM_SOURCE}"
echo "--- START ---"

echo "[*] Assembling of the program source"
java -jar ../material/rars.jar a dump .text BinaryText ../sim/io/program.s mc CompactTextAtZero $PROGRAM_SOURCE

echo "[*] Saving initial snapshot of data memory to file"
java -jar ../material/rars.jar a dump .data BinaryText ../sim/io/data_memory_init.txt mc CompactTextAtZero $PROGRAM_SOURCE

echo "[*] Execution of the program with the simulator"
java -jar ../material/rars.jar $IM_SIZE dump .data BinaryText io/$REF_FILE mc CompactTextAtZero $PROGRAM_SOURCE

#Initialize Modelsim environment
echo "[*] Initialization of ModelSim environment"
source /software/scripts/init_msim6.2g > log/log_sim.txt

#Delete the previous working directory and create a new one
if [ -d ./work ]
	then
	rm -r ./work
fi
vlib work

#Change some lines if version = pro to add abs instruction
if [[ "$VERSION" == "_pro" ]] && [[ "$PROGRAM_SOURCE"!="../material/booth-multiplier.s" ]]
	then
    echo "[!] PRO version (with abs and slli)"
	sed -i "s%01000001111101000101010010010011%00000100000001000000010100110011%" io/program.s
	sed -i "s%00000000100101000100010100110011%00000000000000000000000000010011%" io/program.s
	sed -i "s%00000000000101001111010010010011%00000000000000000000000000010011%" io/program.s
	sed -i "s%00000000100101010000010100110011%00000000000000000000000000010011%" io/program.s
fi

#Set variables and run simulation script on modelsim
echo "[*] ModelSim is running..."
vsim -c -do "set ENTITY_NAME $ENTITY_NAME; set TB_NAME $TB_NAME; set SIM_TIME $SIM_TIME; set VERSION_FOLDER $VERSION_FOLDER; do sim.do" >> log/log_sim.txt

#Check the results
echo "[*] Checking results..."
python3 checker.py io/$REF_FILE io/$OUT_FILE

#Rename the files to avoid overwriting when the checker will be invoked with the synthesis netlist
echo "[*] Results saved to log_check_presyn.txt"
mv io/data_memory_dump.txt io/data_memory_dump_presyn.txt
mv log_check.txt log/log_check_presyn.txt

echo "--- END ---"

#!/bin/bash

#Change here ("" or "_MBE")
VERSION=""

#Variables (do not change)
ENTITY_NAME="FPmul$VERSION"
TB_NAME="tb_FPmul$VERSION"
REF_FILE="fp_prod.hex"
VHD_FILE="results_tb.hex"
SIM_TIME="10us"
PERIOD="5"

CLEAN=""
SYNTHESIS_VERSION=""
BACKANNOTATION=""
INPUT_PATH=""

while getopts "i:v:p:e:c?" OPTION
do
    case $OPTION in
        i)
            INPUT_PATH=$OPTARG
            ;;
        c) 
            CLEAN=1
            ;;
        v)
            SYNTHESIS_VERSION=$OPTARG
            ;;
        p)
            PERIOD=$OPTARG
            ;;
        e)
            ENTITY_NAME=$OPTARG
            TB_NAME="tb_"$OPTARG
            ;;
        ?)
            man ./syn_man.1
            exit
    esac
done

if [[ -z $SYNTHESIS_VERSION ]]; then
    echo "You did not specify a synthesis name!"
    exit 1
fi

if [[ -z $INPUT_PATH ]]; then
    echo "You did not specify an input path! Which path would you like to synthesize?"
    read -p "> " INPUT_PATH
fi

#Initialize Synopsys environment
echo "Automation for the synthesis workflow"
echo "--- START ---"
echo "[*] Initialization of Synopsys environment"
source /software/scripts/init_synopsys_64.18

cd $INPUT_PATH

#Delete the previous working directory and create a new one
if [ -d ./work ] 
then
	rm -r ./work
	echo "[*] Removed previous working directory"
fi

mkdir work

#Create folder for timing, power, area reports
if [[ ! -d ./reports ]]; then
    mkdir reports
fi

if [[ CLEAN -eq 1 ]]; then
    echo "[*] Removal of old reports and logs..."
    REPORT_FILES=$(ls ./reports/ | grep "report")
    LOG_FILES=$(ls | grep "log")

    rm -f $REPORT_FILES
    rm -f $LOG_FILES
fi

echo "[*] Synopsys is running..."
#Run Synopsis and the synthesis script
dc_shell-xg-t -f syn.tcl -x "set SYN_VERSION $SYNTHESIS_VERSION; set ENTITY_NAME $ENTITY_NAME; set PERIOD $PERIOD" > log_syn.txt

#Check the results
if [[ $PERIOD != "0" ]]; then

    cd ../../sim/netlist_sim/
    source /software/scripts/init_msim6.2g
    if [ -d ./work ]; then
	rm -r ./work
    fi
    vlib work
    sed -i "s%constant Ts : time := .*%constant Ts : time := $PERIOD ns;%" ../../tb/clk_gen.vhd
    echo "[*] Modelsim is running..."
    vsim -c -do "set ENTITY_NAME $ENTITY_NAME; set TB_NAME $TB_NAME; set SIM_TIME $SIM_TIME; do netlist_sim.do" > log_sim_postsyn.txt
    echo "[*] Checking results by simulating the generated netlist..."
	cd ..
    python3 checker.py $REF_FILE netlist_sim/$VHD_FILE 
    mv netlist_sim/$VHD_FILE netlist_sim/results_postsyn.txt
    cd ../syn/$INPUT_PATH
fi

echo ""
echo "[AREA REPORT]"
tail -n 10 reports/area_report_$SYNTHESIS_VERSION.txt
echo ""
echo ""
echo "[TIMING REPORT]"
echo ""
tail -n 8 reports/timing_report_setup_$SYNTHESIS_VERSION.txt
echo ""
tail -n 8 reports/timing_report_hold_$SYNTHESIS_VERSION.txt

echo "--- END ---"

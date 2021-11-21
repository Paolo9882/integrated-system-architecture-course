#!/bin/bash

#Change here ("" or "_lookahead")
VERSION="_lookahead"

#Variables (do not change)
ENTITY_NAME="iir_2nd_order$VERSION"
TB_NAME="tb_iir_2nd_order$VERSION"
C_FILE="results_c$VERSION.txt"
VHD_FILE="results_tb.txt"
SIM_TIME="10us"
PERIOD="10.04"

CLEAN=""
SYNTHESIS_VERSION=""
BACKANNOTATION=""

while getopts "v:p:e:cb?" OPTION
do
    case $OPTION in
        c) 
            CLEAN=1
            ;;
        b)
            BACKANNOTATION=1
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

#Initialize Synopsys environment
echo "Automation for the synthesis workflow"
echo "--- START ---"
echo "[*] Initialization of Synopsys environment"
source /software/scripts/init_synopsys_64.18

#Delete the previous working directory and create a new one
if [ -d ./work ] 
then
	rm -r ./work
	echo "[*] Removed previous working directory"
fi

if [[ ! -d ./reports ]]; then
    mkdir reports
fi

mkdir work

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


if [[ $BACKANNOTATION -eq 1 ]]; then
    cd ../sim
    source /software/scripts/init_msim6.2g
    if [ -d ./work ]; then
	    rm -r ./work
    fi
    vlib work
	sed -i "s%constant Ts : time := .*%constant Ts : time := $PERIOD ns;%" ../tb/clk_gen.vhd
    echo "[*] Modelsim is running..."
    vsim -c -do "set ENTITY_NAME $ENTITY_NAME; set TB_NAME $TB_NAME; set SIM_TIME $SIM_TIME; do backannotation_syn.do" > log_backanno_sim.txt
    echo "[*] Checking results by simulating the generated netlist..."
    python3 checker.py $C_FILE $VHD_FILE
    mv results_tb.txt results_postsyn.txt
    mv log_check.txt log_check_postsyn.txt
    
    echo "[*] vcd2saif conversion..."
    vcd2saif -input ../vcd/$ENTITY_NAME.vcd -output ../saif/$ENTITY_NAME.saif
    echo "[*] Generating power report..."
    cd ../syn
    source /software/scripts/init_synopsys_64.18
    dc_shell-xg-t -f backannotation_syn.tcl -x "set SYN_VERSION $SYNTHESIS_VERSION; set ENTITY_NAME $ENTITY_NAME; set TB_NAME $TB_NAME" > log_backanno_syn.txt
    echo ""
    echo "[POWER REPORT]"
    echo ""
    tail -n 14 reports/power_report_backanno_$SYNTHESIS_VERSION.txt
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

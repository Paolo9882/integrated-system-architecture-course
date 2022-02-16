#!/bin/bash

#Variables (do not change)
VERSION="basic"
VERSION_FOLDER="${VERSION}_version"
ENTITY_NAME="riscv_lite"
TB_NAME="tb_riscv_lite"
REF_FILE="data_memory_ref.txt"
OUT_FILE="data_memory_dump.txt"
SIM_TIME="1.250us"
PERIOD="10"

CLEAN=""
SYNTHESIS_NAME=""
BACKANNOTATION=""

while getopts "v:n:p:e:cb?" OPTION
do
    case $OPTION in
        c) 
            CLEAN=1
            ;;
        b)
            BACKANNOTATION=1
            ;;
        n)
            SYNTHESIS_NAME=$OPTARG
            ;;
		v)
			if [[ "$VERSION" == "basic" ]] || [[ "$VERSION" == "pro" ]]; then
            	VERSION=$OPTARG
				VERSION_FOLDER="${VERSION}_version"
			fi
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

if [[ -z $SYNTHESIS_NAME ]]; then
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
    LOG_FILES=$(ls ./log/ | grep "log")

    rm -f $REPORT_FILES
    rm -f $LOG_FILES
fi

echo "[*] Synopsys is running..."
#Run Synopsis and the synthesis script
dc_shell-xg-t -f syn.tcl -x "set SYNTHESIS_NAME $SYNTHESIS_NAME; set ENTITY_NAME $ENTITY_NAME; set PERIOD $PERIOD; set VERSION_FOLDER $VERSION_FOLDER" > log/log_syn.txt

cd ../sim
source /software/scripts/init_msim6.2g
if [ -d ./work ]; then
	rm -r ./work
fi
vlib work

echo "[*] Modelsim is running..."
sed -i "s%constant Ts : time := .*%constant Ts : time := $PERIOD ns;%" ../tb/clk_gen.vhd
vsim -c -do "set ENTITY_NAME $ENTITY_NAME; set TB_NAME $TB_NAME; set SIM_TIME $SIM_TIME; set VERSION_FOLDER $VERSION_FOLDER ; do backannotation_syn.do" > log/log_backanno_sim.txt

echo "[*] Checking results by simulating the generated netlist..."
python3 checker.py io/$REF_FILE io/$OUT_FILE

echo "[*] Results saved to log_check_postsyn.txt"
mv io/data_memory_dump.txt io/data_memory_dump_postsyn.txt
mv log_check.txt log/log_check_postsyn.txt
cd ../syn/
    
if [[ $BACKANNOTATION -eq 1 ]]; then
	echo "[*] Backannotation process..."
    echo "[*] vcd2saif conversion..."
    vcd2saif -input ../vcd/$VERSION_FOLDER/$ENTITY_NAME.vcd -output ../saif/$VERSION_FOLDER/$ENTITY_NAME.saif
    echo "[*] Generating power report..."
    source /software/scripts/init_synopsys_64.18
    dc_shell-xg-t -f backannotation_syn.tcl -x "set SYNTHESIS_NAME $SYNTHESIS_NAME; set ENTITY_NAME $ENTITY_NAME; set TB_NAME $TB_NAME; set VERSION_FOLDER $VERSION_FOLDER" > log/log_backanno_syn.txt
    echo ""
    echo "[POWER REPORT]"
    echo ""
    tail -n 14 reports/power_report_backanno_$SYNTHESIS_NAME.txt
fi

echo ""
echo "[AREA REPORT]"
tail -n 10 reports/area_report_$SYNTHESIS_NAME.txt
echo ""
echo ""
echo "[TIMING REPORT]"
echo ""
tail -n 8 reports/timing_report_setup_$SYNTHESIS_NAME.txt
echo ""
tail -n 8 reports/timing_report_hold_$SYNTHESIS_NAME.txt

echo "--- END ---"

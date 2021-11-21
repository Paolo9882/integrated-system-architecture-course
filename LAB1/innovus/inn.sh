#!/bin/bash

#Change here ("" or "_lookahead")
VERSION="_lookahead"

#Variables (do not change)
ENTITY_NAME="iir_2nd_order$VERSION"
TB_NAME="tb_iir_2nd_order$VERSION"
C_FILE="results_c$VERSION.txt"
VHD_FILE="results_tb.txt"
SIM_TIME="10us"
PERIOD="6.88"

PLACE=1
BACKANNOTATION=0

#Choose options
while getopts "bcp:?" OPTION
do
    case $OPTION in
        b)
			PLACE=0
            BACKANNOTATION=1
            ;;
		c)
			PLACE=1
			BACKANNOTATION=1
			;;
		p)
			PERIOD=$OPTARG
			;;
        ?)
            man ./inn_man.1
            exit
    esac
done

echo "Automation for the Innovus workflow"
echo "--- START ---"

#Initialize Innovus environment
echo "[*] Initialization of Innovus environment"
source /software/scripts/init_innovus17.11

#Configure entity name
sed -i "s%variable ENTITY_NAME.*%variable ENTITY_NAME $ENTITY_NAME%" inn.tcl
sed -i "s%variable ENTITY_NAME.*%variable ENTITY_NAME $ENTITY_NAME%" backannotation_inn.tcl
sed -i "s%set TopLevelDesign.*%set TopLevelDesign "$ENTITY_NAME"%" design.globals

if [[ $PLACE -eq 1 ]]; then
	#Run Innovus
	echo "[*] Innovus is running..."
	innovus -init inn.tcl > log_inn.txt

	#Remove trash
	rm *.cmd
	rm *.log
	rm *.logv
fi

#Backannotation
if [[ $BACKANNOTATION -eq 1 ]]; then
	cd ../sim
    source /software/scripts/init_msim6.2g
    if [ -d ./work ]; then
	    rm -r ./work
    fi
    vlib work
	sed -i "s%constant Ts : time := .*%constant Ts : time := $PERIOD ns;%" ../tb/clk_gen.vhd
    echo "[*] Modelsim is running..."
    vsim -c -do "set ENTITY_NAME $ENTITY_NAME; set TB_NAME $TB_NAME; set SIM_TIME $SIM_TIME; do backannotation_inn.do" > log_backanno_inn.txt
    echo "[*] Checking results by simulating the generated netlist..."
    python3 checker.py $C_FILE $VHD_FILE
    mv results_tb.txt results_postinn.txt
    mv log_check.txt log_check_postinn.txt
    
    echo "[*] Generating power report..."
    cd ../innovus
    source /software/scripts/init_innovus17.11
    innovus -init backannotation_inn.tcl > log_backanno_inn.txt
 
	#Remove trash
	rm *.cmd
	rm *.log
	rm *.logv
fi

echo "--- END ---"

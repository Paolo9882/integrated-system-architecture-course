#!/bin/bash

#Variables (do not change)
VERSION="basic"
VERSION_FOLDER="${VERSION}_version"
ENTITY_NAME="riscv_lite"
TB_NAME="tb_riscv_lite"
REF_FILE="data_memory_ref.txt"
OUT_FILE="data_memory_dump.txt"
SIM_TIME="11us"
PERIOD="10"

PLACE=1
BACKANNOTATION=0

#Choose options
while getopts "v:bcp:e:?" OPTION
do
    case $OPTION in
		v)
			if [[ "$VERSION" == "basic" ]] || [[ "$VERSION" == "pro" ]]; then
            	VERSION=$OPTARG
				VERSION_FOLDER="${VERSION}_version"
			fi
            ;;
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
        e)
            ENTITY_NAME=$OPTARG
            TB_NAME="tb_"$OPTARG
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
sed -i "s%variable VERSION_FOLDER.*%variable VERSION_FOLDER $VERSION_FOLDER%" inn.tcl
sed -i "s%variable ENTITY_NAME.*%variable ENTITY_NAME $ENTITY_NAME%" backannotation_inn.tcl
sed -i "s%variable VERSION_FOLDER.*%variable VERSION_FOLDER $VERSION_FOLDER%" backannotation_inn.tcl
sed -i "s%set TopLevelDesign.*%set TopLevelDesign $ENTITY_NAME%" design.globals
sed -i "s%set IN_DIR.*%set IN_DIR ../netlist/$VERSION_FOLDER%" design.globals

if [[ $PLACE -eq 1 ]]; then
	#Run Innovus
	echo "[*] Innovus is running..."
	innovus -init inn.tcl > log/log_inn.txt

	cd ../sim
    source /software/scripts/init_msim6.2g
    if [ -d ./work ]; then
	    rm -r ./work
    fi
    vlib work
	sed -i "s%constant Ts : time := .*%constant Ts : time := $PERIOD ns;%" ../tb/clk_gen.vhd
    echo "[*] Modelsim is running..."
    vsim -c -do "set ENTITY_NAME $ENTITY_NAME; set TB_NAME $TB_NAME; set SIM_TIME $SIM_TIME; set VERSION_FOLDER $VERSION_FOLDER; do backannotation_inn.do" > log/log_backanno_inn.txt
    echo "[*] Checking results by simulating the generated netlist..."
    python3 checker.py io/$REF_FILE io/$OUT_FILE
    mv io/data_memory_dump.txt io/data_memory_dump_postinn.txt
    mv log_check.txt log/log_check_postinn.txt

  	cd ../innovus

	#Remove trash
	rm *.cmd
	rm *.log
	rm *.logv
fi

#Backannotation
if [[ $BACKANNOTATION -eq 1 ]]; then  
	echo "[*] Backannotation process..."
    echo "[*] Generating power report..."
    source /software/scripts/init_innovus17.11
    innovus -init backannotation_inn.tcl > log/log_backanno_inn.txt
 
	#Remove trash
	rm *.cmd
	rm *.log
	rm *.logv
fi

echo "--- END ---"

# design_vision script to compute power consumption after back-annotation has been done

# Variables
variable version $SYN_VERSION

# Read the netlist in the Verilog file
read_verilog -netlist ../netlist/$ENTITY_NAME.v
# Read the saif file with the activity of all the nodes
read_saif -input ../saif/$ENTITY_NAME.saif -instance $TB_NAME/DUT -unit ns -scale 1
create_clock -name MY_CLK {CLK}
report_power > reports/power_report_backanno_$version.txt 

quit

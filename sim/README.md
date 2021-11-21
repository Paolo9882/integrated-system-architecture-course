## Folder Organisation

This directory contains:

- sim.sh: bash script to inizialize modelsim environment and launch it

- sim.do: modelsim script to automatize simulation (pre-synthesis)

- checker.py: python script to check simualtion results

- backannotation_*.do: modelsim script to automatize simulation (post-synthesis and post-place&route)

- samples.txt: simulation input data 

- results_*.vhd: simulation output data / expected data

- log_sim.txt: modelsim simulation log file (we deleted it to keep the project clean)

- log_check_*.txt: checker log file

- log_backanno_*.txt: backannotation log file (we deleted them to keep the project clean)


## How to perform simulation

1) Edit "VERSION" variable in sim.sh (accordingly to what you want to simulate)

2) Open terminal

3) Execute "./sim.sh"

## Folder Organisation

This directory contains:

- sim.sh: bash script to inizialize ModelSim environment and launch it and execute a .do script

- checker.py: Python script to check simualtion results

- fp_samples.hex: simulation input data (expressed in hex format) 

- fp_prod.hex: simulation output data / expected data

- log_check.txt: checker log file

Then we have many folders, one for the simulation of each different version of the design that has to be tested. 
Every folder contains a "sim.do" script that is run by ModelSim.

The different folders are:

- fpmul_pipeline: this folder can be used to test the ORIGINAL FP Multiplier, as download from Portale

- fpmul_pipeline_inregs: this folder can be used to test the FP Multiplier with added input registers

- fpmul_pipeline_finegrain: this folder can be used to test the FP Multiplier that has input registers and a pipe level at the end of stage 2

- fpmul_mbe: FP Multiplier with MBE significand multiplier and RCA as a last stage

- fpmul_mbe_fastadder: FP Multiplier with MBE significand multiplier and behavioral adder as a last stage (implemented as pparch adder)

- netlist_sim: this folder can be used to simulate whatever netlist is present in the netlist/ folder


## How to perform simulation

1) Edit VERSION variable in sim.sh

2) Edit INPUT_FOLDER variable in sim.sh with one of the folder names in this directory (fpmul_pipeline, ...)

3) Open terminal

4) Execute "./sim.sh". If an INPUT_FOLDER was not specified, it will be asked at this point.

The output of the simulation will be in the folder of the .do script together with the ModelSim WORK folder.

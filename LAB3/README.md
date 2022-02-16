# RISC-V-lite

## Basic informations

The description VHDL files are under the __src/__ directory. The testbench files are located in the __tb/__ directory. 
- To simulate the design go into the __sim/__ directory and:
  `sim.sh <path/to/assembly/file> <basic/pro>`
- To synthesize it, go into the __syn/__ directory and:
  `syn.sh <options> <arguments>` (more information by executing `syn.sh -?`)
- To do P&R automatically go into __innovus/__ directory and:
  `inn.sh <options> <arguments>` (more information by executing `inn.sh -?`)

![RISC-V P&R](https://github.com/drvladbancila/ISA_GR16/blob/feb69e727e87fdacb145b83f39dacdfc15be63bd/LAB3/innovus/snapshot/basic_version/ss_riscv_lite.place.gif)

## Folder Organisation

Lab3 is organised in the following folders:

- **material**: the directory containing all the provided material

- **src**: the directory containing the VHDL files of the processor

- **tb**: the directory containing the VHDL and the verilog files of the test-bench

- **sim**: the directory containing the project files created by modelsim and the simulation scripts

- **syn**: the directory containing the synthesis scripts and the working files produced by the logic synthesizer

- **netlist**: the directory containing the verilog output netlists of the synthesis and the place & route processes

- **vcd**: the directory containing the vcd files (record switching activity from modelsim)

- **saif**: the directory containing the saif files (converted switching activity for synthesis)

- **innovus**: the directory containing the place and route files and results


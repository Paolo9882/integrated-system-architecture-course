## Folder Organisation

This directory contains:

- syn.sh: bash script to inizialize Synopsys environment and launch it

- syn.man1: syn.sh manual

- syn.tcl: synopsys script to automatize synthesis

- backannotation_syn.tcl: synopsys script to automatize synthesis (backannotation process)

- .synopsys_dc.setup: setup information file

- log_syn.txt: synopsys synthesis log file (we deleted it to keep the project clean)

- log_backanno_syn.txt: synopsys synthesis log file for the backannotation process (we deleted it to keep the project clean)

- reports folder


## How to perform synthesis

1) Edit VERSION variable in syn.sh (accordingly to what you want to synthesize)

2) Open terminal

3) Execute "./syn.sh [OPTIONS]". A manual for this script is present ("./syn.sh -?" to read it)


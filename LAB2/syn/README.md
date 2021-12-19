## Folder Organisation

This directory contains the files needed for the synthesis of the various architectures.

The directory contains the following files:

- syn.sh: script that initializes Synopsys' environment and launches Design Compiler

- syn.man1: syn.sh manual

And the following folders:

    - fpmul
    - fpmul_CSA (significand multiplier based on CSA)
    - fpmul_PPARCH (significand multiplier based on PPARCH)
	- fpmul_finegrain (one pipe level at the end of stage2)
	- fpmul_ultra (for the synthesis with compile_ultra)
	- fpmul_mbe (significand multiplier based on MBE)
	- fpmul_mbe_fastadder (MBE with behavioral adder as a last stage, implemented as pparch during synthesis)
    
Every folder contains a .tcl script that is executed by syn.sh depending on the 
architecture that you want to synthesize. Every .tcl scripts contains different 
instructions tailored for that synthesis (resource allocation etc.).

To perform the synthesis, type:
./syn.sh -v <LABEL> -p <CLOCK_PERIOD> 
and then you will be asked the name of the folder of the version that you wish to synthesize (fpmul, fpmul_CSA, ...).
All the results and the reports will be stored inside that folder.


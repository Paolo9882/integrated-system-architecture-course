-- HAZARD DETECTION UNIT
-- if a data hazard with the previous operation is present, and that operation is a LW, 
-- stop the progress of the PC and of the pipe registers and turn the MUX to generate a BUBBLE. 

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY HDU is
	GENERIC(
		ADD_WIDTH : integer := 5
	);
	PORT(
		REG_READ1		: IN std_logic_vector (ADD_WIDTH-1 DOWNTO 0); --address of register coming from control
		REG_READ2		: IN std_logic_vector (ADD_WIDTH-1 DOWNTO 0); --address of register coming from control
		REG_DEST_PREV	: IN std_logic_vector (ADD_WIDTH-1 DOWNTO 0); --address of register coming EX stage
		MEM_PREV		: IN std_logic_vector (1 DOWNTO 0); --signal coming from ex stage
															--MEM_PREV(0) is the CS of the memory ('1' means an access to the memory)
															--MEM_PREV(1) is R_Wn of the memory ('1' means read operation, LW, '0' means SW)
		EN_PC			: OUT std_logic;
		EN_PIPE			: OUT std_logic;
		EN_NEXT_OP		: OUT std_logic
	);
END HDU;

ARCHITECTURE behaviour OF HDU IS

BEGIN

PROCESS(MEM_PREV, REG_READ1, REG_READ2, REG_DEST_PREV)

BEGIN
	--if the previous operation is a load
	IF (MEM_PREV = "11") THEN			
		--if there is an hazard 
		IF ( REG_READ1 = REG_DEST_PREV OR REG_READ2 = REG_DEST_PREV ) THEN
			--generate a bubble
			EN_PC <= '0';
			EN_PIPE <= '0';
			EN_NEXT_OP <= '0';
		ELSE
			--do nothing
			EN_PC <= '1';
			EN_PIPE <= '1';
			EN_NEXT_OP <= '1';
		END IF;
	ELSE
		--do nothing
		EN_PC <= '1';
		EN_PIPE <= '1';
		EN_NEXT_OP <= '1';	
	END IF;	
					
END PROCESS;

END behaviour;

-- MULTIPLEXER CONTROLLED BY THE HAZARD DETECTION UNIT
-- SEL = '1' => normal execution
-- SEL = '0' => bubble

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY hazard_mux is
	GENERIC(
		ADD_WIDTH : integer := 5
	);
	PORT(
		REG_READ1		: IN  std_logic_vector (ADD_WIDTH-1 DOWNTO 0);
		REG_READ2		: IN  std_logic_vector (ADD_WIDTH-1 DOWNTO 0);
		REG_DEST		: IN  std_logic_vector (ADD_WIDTH-1 DOWNTO 0);
		EX_MUX			: IN  std_logic_vector (3 DOWNTO 0);
		MEM_MUX			: IN  std_logic_vector (1 DOWNTO 0);
		WB_MUX			: IN  std_logic_vector (1 downto 0);
		SEL				: IN  std_logic;
		REG_READ1_EX	: OUT std_logic_vector (ADD_WIDTH-1 DOWNTO 0);
		REG_READ2_EX	: OUT std_logic_vector (ADD_WIDTH-1 DOWNTO 0);
		REG_DEST_EX		: OUT std_logic_vector (ADD_WIDTH-1 DOWNTO 0);
		EX_CONTROL		: OUT std_logic_vector (3 DOWNTO 0);
		MEM_CONTROL 	: OUT std_logic_vector (1 DOWNTO 0);
		WB_CONTROL 		: OUT std_logic_vector (1 downto 0)
	);
END hazard_mux;

ARCHITECTURE behaviour OF hazard_mux IS

BEGIN

PROCESS(REG_READ1, REG_READ2, REG_DEST, EX_MUX, MEM_MUX, WB_MUX, SEL)

BEGIN 

	IF (SEL = '0') THEN
		EX_CONTROL 		<= (others => '0');
		MEM_CONTROL 	<= "00";
		WB_CONTROL		<= (others => '0');
		REG_DEST_EX 	<= (others => '0');
		REG_READ1_EX	<= (others => '0');
		REG_READ2_EX	<= (others => '0');
	ELSE
		EX_CONTROL 		<= EX_MUX;
		MEM_CONTROL	 	<= MEM_MUX;
		WB_CONTROL		<= WB_MUX;
		REG_DEST_EX 	<= REG_DEST;
		REG_READ1_EX	<= REG_READ1;
		REG_READ2_EX	<= REG_READ2;
	END IF;	
					
END PROCESS;

END behaviour;

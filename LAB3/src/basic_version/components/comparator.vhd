-- COMPARATOR
-- EQUAL		 => '1'
-- DIFFERENT	 => '0'

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY comparator is
	GENERIC(
		DATA_WIDTH : integer := 32
	);
	PORT(
		INPUT1		: IN std_logic_vector (DATA_WIDTH-1 DOWNTO 0); --input 1
		INPUT2		: IN std_logic_vector (DATA_WIDTH-1 DOWNTO 0); --input 2
		EN			: IN std_logic; -- enable 
		OUTPUT		: OUT std_logic
	);
END comparator;

ARCHITECTURE behaviour OF comparator IS

BEGIN

PROCESS(INPUT1, INPUT2, EN)

BEGIN
	IF ( EN = '1' ) THEN
		IF ( INPUT1 = INPUT2 ) THEN			
			OUTPUT <= '1';
		ELSE 
			OUTPUT <= '0';
		END IF;	
	ELSE
		OUTPUT <= '0';
	END IF;
			
END PROCESS;

END behaviour;

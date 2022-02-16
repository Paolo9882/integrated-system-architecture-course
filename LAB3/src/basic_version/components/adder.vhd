-- ADDER
-- NO OVERFLOW CHECK

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
	generic(
		DATA_WIDTH	: integer := 32
	);
	port(
		INPUT1		: in  std_logic_vector(DATA_WIDTH-1 downto 0);
		INPUT2		: in  std_logic_vector(DATA_WIDTH-1 downto 0);
		OUTPUT		: out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end adder;


architecture behaviour of adder is

begin

OUTPUT <= std_logic_vector( signed(INPUT1) + signed(INPUT2) );

end behaviour;

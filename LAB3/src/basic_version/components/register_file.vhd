-- REGISTER FILE

-- combinatorial reading of two data
-- one writing for each clock cycle

-- NO FORWARDING!

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
	generic(
		DATA_WIDTH		: integer := 32;
		PARALLELISM		: integer := 5 -- number of data
	);
	port(
		REG_READ1	: in  std_logic_vector(PARALLELISM-1 downto 0);
		REG_READ2	: in  std_logic_vector(PARALLELISM-1 downto 0);
		REG_WRITE	: in  std_logic_vector(PARALLELISM-1 downto 0);
		DATA_WRITE	: in  std_logic_vector(DATA_WIDTH-1 downto 0);
		EN_W		: in  std_logic;
		RST_n		: in  std_logic;
		CLK         : in  std_logic;
		DATA_READ1	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		DATA_READ2	: out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end register_file;


architecture behaviour of register_file is

	type registerFile is array(0 to 31) of std_logic_vector(DATA_WIDTH-1 downto 0);
	signal registers : registerFile;

begin

write : process (CLK, RST_n, EN_W)
begin
	if ( RST_n = '1' ) then
		--synchronous writing
		if ( rising_edge(CLK) and EN_W = '1' ) then
				--WRITE DATA
				registers(to_integer(unsigned(REG_WRITE))) <= DATA_WRITE;
		end if;
	else
		registers <= (others => (others => '0'));
	end if;
end process;

-- READ ALWAYS DATA
DATA_READ1 <= registers(to_integer(unsigned(REG_READ1)));
DATA_READ2 <= registers(to_integer(unsigned(REG_READ2)));

end behaviour;

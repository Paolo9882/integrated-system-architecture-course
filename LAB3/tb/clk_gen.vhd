library ieee;
use ieee.std_logic_1164.all;

-- clk and rst_n generator
entity clk_gen is
	port(
		END_SIM : in  std_logic;
		FLASHED_IM : in std_logic;
		FLASHED_DM : in std_logic;
    	CLK     : out std_logic;
		RST_n   : out std_logic
		);
end clk_gen;

architecture beh of clk_gen is

	constant Ts : time := 3.56 ns;

	signal CLK_i : std_logic;
	signal RST_n_i : std_logic := '0';

begin

	-- clk generation
	process
	begin
		if (CLK_i = 'U') then
			CLK_i <= '0';
		else
			CLK_i <= not(CLK_i);
		end if;
		wait for Ts/2;
	end process;

	CLK <= CLK_i and not(END_SIM);
	RST_n <= RST_n_i;

	-- rst_n generation
	process(CLK_i)
	begin
		if (rising_edge(CLK_i)) then
			RST_n_i <= FLASHED_IM and FLASHED_DM after Ts/10;
		end if;
	end process;

end beh;

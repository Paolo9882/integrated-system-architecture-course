library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

--input data generator
entity data_gen_lookahead is  
	port (
		CLK     : in  std_logic;
		RST_n   : in  std_logic;
		VOUT    : out std_logic;
		DOUT    : out std_logic_vector(11 downto 0);
		a2 		: out std_logic_vector(11 downto 0);
    	a3      : out std_logic_vector(11 downto 0);
    	b0      : out std_logic_vector(11 downto 0);
    	b1      : out std_logic_vector(11 downto 0);
    	b2      : out std_logic_vector(11 downto 0);
    	b3      : out std_logic_vector(11 downto 0);
    	END_SIM : out std_logic);
end data_gen_lookahead;

architecture beh of data_gen_lookahead is

	constant tco : time := 1 ns;

	signal sEndSim : std_logic;
	signal END_SIM_i : std_logic_vector(0 to 10);  

begin

	a2 <= std_logic_vector((to_signed(-122,a2'length)));
	a3 <= std_logic_vector((to_signed(-149,a3'length)));
	b0 <= std_logic_vector((to_signed(423,b0'length)));
	b1 <= std_logic_vector((to_signed(1002,b1'length)));
	b2 <= std_logic_vector((to_signed(735,b2'length)));
	b3 <= std_logic_vector((to_signed(156,b3'length)));

	--read input data from file
	process (CLK, RST_n)
	    variable pause: integer := 0; --variable used to simulate Vin: '1' -> '0' -> '1'
		file data_in : text open READ_MODE is "./samples.txt";
		variable line_in : line;
		variable x : integer;
	begin
		if RST_n = '0' then
		    pause := 0;
			DOUT <= (others => '0') after tco;      
			VOUT <= '0' after tco;
			sEndSim <= '0' after tco;
		elsif CLK'event and CLK = '1' then
		    pause := pause + 1; 
			if not endfile(data_in) then
				if (pause < 100 or pause >= 105) then	--normal read from file	
  					readline(data_in, line_in);
					read(line_in, x);
					DOUT <= std_logic_vector(to_signed(x, DOUT'length)) after tco;
					VOUT <= '1' after tco;
				else	--enable signal goes off for a while (test Vin behaviour)
					DOUT <= std_logic_vector(to_signed(x, DOUT'length)) after tco;
					VOUT <= '0' after tco;
				end if;
				sEndSim <= '0' after tco;
			else
				DOUT <= (others => '0') after tco;  
				VOUT <= '0' after tco;        
				sEndSim <= '1' after tco;
			end if;
		end if;
	end process;

	--simulation ends after a while
	process (CLK, RST_n)
	begin
		if RST_n = '0' then 
			END_SIM_i <= (others => '0') after tco;
		elsif CLK'event and CLK = '1' then
			END_SIM_i(0) <= sEndSim after tco;
			END_SIM_i(1 to 10) <= END_SIM_i(0 to 9) after tco;	
		end if;
	end process;

	END_SIM <= END_SIM_i(10);  

end beh;

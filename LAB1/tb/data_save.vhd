library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

--output data writer
entity data_save is
	port(
		CLK   : in std_logic;
		RST_n : in std_logic;
		VIN   : in std_logic;
		DIN   : in std_logic_vector(11 downto 0));
end data_save;

architecture beh of data_save is

begin

	--write output data on file
	process (CLK, RST_n)
		file data_out : text open WRITE_MODE is "./results_tb.txt";
		variable line_out : line;    
	begin
		if RST_n = '0' then
			null;
		elsif rising_edge(CLK) then
			if VIN = '1' then
 				write(line_out, to_integer(signed(DIN)));
 				--write(line_out, VIN); --line used to check the behavior of VOUT
				writeline(data_out, line_out);
			end if;
		end if;
	end process;

end beh;

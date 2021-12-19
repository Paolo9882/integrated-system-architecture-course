library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity data_maker is
  port (
    CLK  : in  std_logic;
    DATA : out std_logic_vector(31 downto 0);
    RST_n: in std_logic;
    END_SIM : out std_logic);
end data_maker;

architecture beh of data_maker is

constant tco : time := 1 ns;

signal sEndSim : std_logic;
signal END_SIM_i : std_logic_vector(0 to 10);  

begin  -- beh

  process (CLK, RST_n)
    file fp : text open read_mode is "./../fp_samples.hex";
    variable ptr : line;
    variable val : std_logic_vector(31 downto 0);
  begin  -- process
  
    if RST_n = '0' then
        sEndSim <= '0' after tco;
        DATA <= (others => '0') after tco; 
    elsif rising_edge(CLK) then  -- rising clock edge
      if (not(endfile(fp))) then
        readline(fp, ptr);
        hread(ptr, val);
        DATA <= val;
      else
        DATA <= (others => '0') after tco; 
        sEndSim <= '1' after tco;         
      end if;
    end if;
  end process;
  
  process (CLK, RST_n)
  begin
	if RST_n = '0' then 
		END_SIM_i <= (others => '0') after tco;
	elsif rising_edge(CLK) then
		END_SIM_i(0) <= sEndSim after tco;
		END_SIM_i(1 to 10) <= END_SIM_i(0 to 9) after tco;
	end if;
  end process;

  END_SIM <= END_SIM_i(10);  

end beh;

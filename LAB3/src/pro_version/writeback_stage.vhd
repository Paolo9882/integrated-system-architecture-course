library ieee;
use ieee.std_logic_1164.all;

--Write Back stage
entity writeback_stage is
	port(
		en_load: in std_logic; --enable load data condition
		result_write: in std_logic_vector(31 downto 0); --computed result
		data_load: in std_logic_vector(31 downto 0); --loaded data
		data_wb: out std_logic_vector(31 downto 0) --data to be written back
	);
end writeback_stage;

architecture structural of writeback_stage is

	begin

		--write result / load data multiplexer
		data_wb <= 	result_write	when en_load = '0' else	--write result condition
					data_load; 	--load data condition

end structural;

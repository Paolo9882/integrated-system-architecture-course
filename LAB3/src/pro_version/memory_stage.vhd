library ieee;
use ieee.std_logic_1164.all;

--Memory stage
entity memory_stage is
	port(
		in_addr: in std_logic_vector(31 downto 0); --input data memory address
		in_data_to_mem: in std_logic_vector(31 downto 0); --input data to data memory
		in_data_from_mem: in std_logic_vector(31 downto 0); --input data from data memory
		out_addr: out std_logic_vector(31 downto 0); --output data memory address
		out_data_to_mem: out std_logic_vector(31 downto 0); --output data to data memory
		out_data_from_mem: out std_logic_vector(31 downto 0) --output data from data memory
	);
end memory_stage;

architecture structural of memory_stage is

	begin

		--wire's connections
		out_addr <= in_addr;
		out_data_to_mem <= in_data_to_mem;
		out_data_from_mem <= in_data_from_mem;

end structural;


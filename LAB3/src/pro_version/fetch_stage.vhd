library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Fetch stage
entity fetch_stage is
	port(
		PC_addr: in std_logic_vector(31 downto 0); --input program counter current address
		jump_addr: in std_logic_vector(31 downto 0); --jump address
		en_jump: in std_logic; --enable jump condition
		in_instr_from_memory: in std_logic_vector(31 downto 0); --input instruction from instruction memory
		curr_addr: out std_logic_vector(31 downto 0); --output program counter current address
		next_addr: out std_logic_vector(31 downto 0); --program counter next address
		out_instr_from_memory: out std_logic_vector(31 downto 0) --output instruction from instruction memory
	);
end fetch_stage;

architecture structural of fetch_stage is

	--signals
	signal seq_addr: std_logic_vector(31 downto 0); --next sequential address

	begin

		--adder (sequential address computation)
		seq_addr <= std_logic_vector(unsigned(PC_addr) + 4);

		--sequential / jump multiplexer
		next_addr <= 	seq_addr	when en_jump = '0' else	--sequential condition
						jump_addr; 	--jump condition

		--wire's connections
		curr_addr <= PC_addr;
		out_instr_from_memory <= in_instr_from_memory;

end structural;

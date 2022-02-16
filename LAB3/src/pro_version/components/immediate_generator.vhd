-- IMMEDIATE GENERATOR

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity immediate_generator is
	generic(
		DATA_WIDTH		: integer := 32
	);
	port(
		INSTRUCTION	: in  std_logic_vector(DATA_WIDTH-1 downto 0);
		IMM_TYPE	: in  std_logic_vector(2 DOWNTO 0);
		IMMEDIATE	: out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end immediate_generator;


architecture behaviour of immediate_generator is

begin

process (INSTRUCTION, IMM_TYPE)
  
begin

	--initialize all the bits to the sign bit of the immediate
	IMMEDIATE <= (others => INSTRUCTION(31));

	case IMM_TYPE is
		when "000" => -- I-immediate
			IMMEDIATE(10 downto 5) <= INSTRUCTION(30 downto 25);
			IMMEDIATE(4 downto 1) <= INSTRUCTION(24 downto 21);				
			IMMEDIATE(0) <= INSTRUCTION(20);
		when "001" => -- S-immediate
			IMMEDIATE(10 downto 5) <= INSTRUCTION(30 downto 25);
			IMMEDIATE(4 downto 1) <= INSTRUCTION(11 downto 8);				
			IMMEDIATE(0) <= INSTRUCTION(7);
		when "010" => -- B-immediate
			IMMEDIATE(11) <= INSTRUCTION(7);			
			IMMEDIATE(10 downto 5) <= INSTRUCTION(30 downto 25);
			IMMEDIATE(4 downto 1) <= INSTRUCTION(11 downto 8);				
			IMMEDIATE(0) <= '0';			
		when "011" => -- U-immediate
			IMMEDIATE(30 downto 20) <= INSTRUCTION(30 downto 20);	
			IMMEDIATE(19 downto 12) <= INSTRUCTION(19 downto 12);					
			IMMEDIATE(11 downto 0) <= (others => '0');
		when "100" => -- U-immediate	
			IMMEDIATE(19 downto 12) <= INSTRUCTION(19 downto 12);		
			IMMEDIATE(11) <= INSTRUCTION(20);		
			IMMEDIATE(10 downto 5) <= INSTRUCTION(30 downto 25);	
			IMMEDIATE(4 downto 1) <= INSTRUCTION(24 downto 21);				
			IMMEDIATE(0) <= '0';			
		when others =>
			IMMEDIATE <= (others => '0');
		end case;

end process;

end behaviour;

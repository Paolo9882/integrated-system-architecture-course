library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Partial product generation
entity pp_generation is
	port(
		a: in std_logic_vector(31 downto 0); --multiplicand
		x: in std_logic_vector(31 downto 0); --multiplier
		pp0: out std_logic_vector(36 downto 0); --partial products
		pp1: out std_logic_vector(36 downto 0);
		pp2: out std_logic_vector(36 downto 0);
		pp3: out std_logic_vector(36 downto 0);
		pp4: out std_logic_vector(36 downto 0);
		pp5: out std_logic_vector(36 downto 0);
		pp6: out std_logic_vector(36 downto 0);
		pp7: out std_logic_vector(36 downto 0);
		pp8: out std_logic_vector(36 downto 0);
		pp9: out std_logic_vector(36 downto 0);
		pp10: out std_logic_vector(36 downto 0);
		pp11: out std_logic_vector(36 downto 0);
		pp12: out std_logic_vector(36 downto 0);
		pp13: out std_logic_vector(36 downto 0);
		pp14: out std_logic_vector(36 downto 0);
		pp15: out std_logic_vector(36 downto 0);
		pp16: out std_logic_vector(36 downto 0)
	);
end pp_generation;

architecture structural of pp_generation is

	--signals
	type sel_array is array(16 downto 0) of std_logic_vector(1 downto 0);
	signal sel: sel_array; --mux selectors
	type multiplicand_array is array(16 downto 0) of std_logic_vector(32 downto 0);
	signal int_multiplicand, int_pp: multiplicand_array; --internal multiplicands and partial products
	signal int_multiplier: std_logic_vector(34 downto 0); --internal multiplier
	signal sign: std_logic_vector(16 downto 0); --internal multiplicand's signs

	--BRU component
	component bru is
		port(
			torec0, torec1, torec2: in std_logic;
			recoded0, recoded1: out std_logic
		);
	end component;

	begin

		--multiplier extension
		int_multiplier <= '0' & '0' & x & '0';

		--BRUs port map
		BRU_gen: for i in 0 to 16 generate
			BRUs: bru 
				port map(
					torec0 => int_multiplier(2*i),
					torec1 => int_multiplier(2*i+1),
					torec2 => int_multiplier(2*i+2),
					recoded0 => sel(i)(0),
					recoded1 => sel(i)(1)
				);
			sign(i) <= int_multiplier(2*i+2);
		end generate;
	
		--multiplicand multiplexers
		MUX_gen: for i in 0 to 16 generate
			int_multiplicand(i) <= 	(others => '0') when sel(i) = "00" else --internal multiplicand : 0
									'0' & a 		when sel(i) = "01" else --internal multiplicand : a
									a & '0' 		when sel(i) = "10"; 	--internal multiplicand : 2*a
			--invert internal multiplicand bits if multiplicand's sign is negative to generate internal partial products
			PP_gen: for j in 0 to 32 generate
				int_pp(i)(j) <= int_multiplicand(i)(j) xor sign(i); 
			end generate;
		end generate;
		
		--sign extensions and output partial product generation
		pp0 <= '0' & not(sign(0)) & sign(0) & sign(0) & int_pp(0);
		pp1 <= '1' & not(sign(1)) & int_pp(1) & '0' & sign(0);
		pp2 <= '1' & not(sign(2)) & int_pp(2) & '0' & sign(1);
		pp3 <= '1' & not(sign(3)) & int_pp(3) & '0' & sign(2);	
		pp4 <= '1' & not(sign(4)) & int_pp(4) & '0' & sign(3);
		pp5 <= '1' & not(sign(5)) & int_pp(5) & '0' & sign(4);
		pp6 <= '1' & not(sign(6)) & int_pp(6) & '0' & sign(5);
		pp7 <= '1' & not(sign(7)) & int_pp(7) & '0' & sign(6);
		pp8 <= '1' & not(sign(8)) & int_pp(8) & '0' & sign(7);
		pp9 <= '1' & not(sign(9)) & int_pp(9) & '0' & sign(8);
		pp10 <= '1' & not(sign(10)) & int_pp(10) & '0' & sign(9);
		pp11 <= '1' & not(sign(11)) & int_pp(11) & '0' & sign(10);
		pp12 <= '1' & not(sign(12)) & int_pp(12) & '0' & sign(11);
		pp13 <= '1' & not(sign(13)) & int_pp(13) & '0' & sign(12);
		pp14 <= '1' & not(sign(14)) & int_pp(14) & '0' & sign(13);
		pp15 <= '0' & not(sign(15)) & int_pp(15) & '0' & sign(14);
		pp16 <= '0' & '0' & int_pp(16) & '0' & sign(15);

end structural;


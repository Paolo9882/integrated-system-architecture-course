library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--MBE Multiplier (Modified Booth Encoding)
entity mbe_mult is
	port(
		a: in std_logic_vector(31 downto 0); --multiplicand
		x: in std_logic_vector(31 downto 0); --multiplier
		p : out std_logic_vector(63 downto 0) --product
	);
end mbe_mult;

architecture structural of mbe_mult is

	--signals
	type pp_array is array(16 downto 0) of std_logic_vector(36 downto 0);
	signal int_pp: pp_array; --internal partial products
	signal int_final0, int_final1: std_logic_vector(63 downto 0); --internal final two addends

	--components
	component pp_generation is
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
	end component;

	component dadda_tree is
	port(
		pp0: in std_logic_vector(36 downto 0); --partial products
		pp1: in std_logic_vector(36 downto 0);
		pp2: in std_logic_vector(36 downto 0);
		pp3: in std_logic_vector(36 downto 0);
		pp4: in std_logic_vector(36 downto 0);
		pp5: in std_logic_vector(36 downto 0);
		pp6: in std_logic_vector(36 downto 0);
		pp7: in std_logic_vector(36 downto 0);
		pp8: in std_logic_vector(36 downto 0);
		pp9: in std_logic_vector(36 downto 0);
		pp10: in std_logic_vector(36 downto 0);
		pp11: in std_logic_vector(36 downto 0);
		pp12: in std_logic_vector(36 downto 0);
		pp13: in std_logic_vector(36 downto 0);
		pp14: in std_logic_vector(36 downto 0);
		pp15: in std_logic_vector(36 downto 0);
		pp16: in std_logic_vector(36 downto 0);		
		final0: out std_logic_vector(63 downto 0); --final two addends
		final1: out std_logic_vector(63 downto 0)
	);
	end component;

	begin

		--components map
		PP_gen: pp_generation 
				port map(
					a => a,
					x => x,
					pp0 => int_pp(0),
					pp1 => int_pp(1),
					pp2 => int_pp(2),
					pp3 => int_pp(3),
					pp4 => int_pp(4),
					pp5 => int_pp(5),
					pp6 => int_pp(6),
					pp7 => int_pp(7),
					pp8 => int_pp(8),
					pp9 => int_pp(9),
					pp10 => int_pp(10),
					pp11 => int_pp(11),
					pp12 => int_pp(12),
					pp13 => int_pp(13),
					pp14 => int_pp(14),
					pp15 => int_pp(15),
					pp16 => int_pp(16)
				);

		tree: dadda_tree
				port map(
					pp0 => int_pp(0),
					pp1 => int_pp(1),
					pp2 => int_pp(2),
					pp3 => int_pp(3),
					pp4 => int_pp(4),
					pp5 => int_pp(5),
					pp6 => int_pp(6),
					pp7 => int_pp(7),
					pp8 => int_pp(8),
					pp9 => int_pp(9),
					pp10 => int_pp(10),
					pp11 => int_pp(11),
					pp12 => int_pp(12),
					pp13 => int_pp(13),
					pp14 => int_pp(14),
					pp15 => int_pp(15),
					pp16 => int_pp(16),
					final0 => int_final0,
					final1 => int_final1
				);

		p <= std_logic_vector(unsigned(int_final0) + unsigned(int_final1));

end structural;

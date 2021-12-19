library ieee;
use ieee.std_logic_1164.all;

--RCA (Ripple Carry Adder)
entity rca is
	port(
		a, b : in std_logic_vector(63 downto 0); --addends
		cin : in std_logic; --carry in
		s : out std_logic_vector(63 downto 0); --sum
		cout : out std_logic --carry out
	);
end rca;

architecture structural of rca is

	--signals
	signal int_carry : std_logic_vector(64 downto 0);

	--full adder component
	component full_adder is
		port(
			a, b, cin : in std_logic; --addends and carry in
			s, cout : out std_logic --sum and carry out
		);
	end component;

	begin

		--full adders map
		FA_gen: for i in 0 to 63 generate
			FA: full_adder 
				port map(
					a => a(i),
					b => b(i),
					cin => int_carry(i),
					s => s(i),
					cout => int_carry(i+1)
				);
		end generate;

		--first and last carries
		int_carry(0) <= cin;
		cout <= int_carry(64);

end structural;

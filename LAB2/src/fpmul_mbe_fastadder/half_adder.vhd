library ieee;
use ieee.std_logic_1164.all;

--Half adder
entity half_adder is
	port(
		a, b : in std_logic; --addends
		s, cout : out std_logic --sum and carry out
	);
end half_adder;

architecture structural of half_adder is

	begin

		s <= a xor b;
		cout <= a and b;

end structural;

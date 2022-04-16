library ieee;
use ieee.std_logic_1164.all;

--Full adder
entity full_adder is
	port(
		a, b, cin : in std_logic; --addends and carry in
		s, cout : out std_logic --sum and carry out
	);
end full_adder;

architecture structural of full_adder is

	begin

		s <= (a xor b) xor cin;
		cout <= ((a xor b) and cin) or (a and b);

end structural;

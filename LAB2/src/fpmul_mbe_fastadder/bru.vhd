library ieee;
use ieee.std_logic_1164.all;

--BRU (Booth Recording Unit)
entity bru is
	port(
		torec0, torec1, torec2 : in std_logic; --inputs to be recoded
		recoded0, recoded1: out std_logic --recoded outputs
	);
end bru;

architecture structural of bru is

	begin

		recoded0 <= torec0 xor torec1;
		recoded1 <= (not(torec0) and not(torec1) and torec2) or (torec0 and torec1 and not(torec2));

end structural;

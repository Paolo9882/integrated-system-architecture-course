library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--IIR filter designed with direct form 2 structure
--operations done with numeric_std operators
--external data parallelism: 12
--filter order: 2
--internal parallelism: 7
--latency: 2 clock cycles

entity iir_2nd_order is
	port(
		DIN, a1, a2, b0, b1, b2: in std_logic_vector(11 downto 0);
		VIN, RST_n, CLK: in std_logic;
		DOUT: out std_logic_vector(11 downto 0);
		VOUT: out std_logic
	);
end iir_2nd_order;

architecture behaviour of iir_2nd_order is

--signals 
signal x_n, sig_1, sig_2, sig_3, y_n: signed (11 downto 0);	--signals exiting by registers
signal a_1, a_2, b_0, b_1, b_2: signed (11 downto 0); 		--external coefficients
signal Vin_L: std_logic;  									--signal used to match the latency of the filter with Vout
signal m1, m2, m3, m4, m5 : signed (23 downto 0); 			--signals exiting from multipliers

begin

registers: process(CLK, RST_n)
begin

--registers enabled by Vin implementation
if (RST_n = '1') then
	if rising_edge(CLK) then
		if (VIN = '1') then
			x_n <= signed(DIN);		--input signal
			sig_2 <= sig_1;			--internal registers signal
			sig_3 <= sig_2;			--internal registers signal
		end if;
	end if;
else
	x_n <= (others => '0');
	sig_2 <= (others => '0');
	sig_3 <= (others => '0');
end if;

--registers always running implementation
if (RST_n = '1') then
	if (rising_edge(CLK)) then
		a_1 <= signed(a1(11 downto 0));
		a_2 <= signed(a2(11 downto 0));
		b_1 <= signed(b1(11 downto 0));
		b_2 <= signed(b2(11 downto 0));
		b_0 <= signed(b0(11 downto 0));
		DOUT <= std_logic_vector(y_n);
		Vin_L <= VIN;					
		VOUT <= Vin_L;					--used to match Vout with corresponding output data
	end if;	
else
	a_1 <= (others => '0');
	a_2 <= (others => '0');
	b_0 <= (others => '0');
	b_1 <= (others => '0');
	b_2 <= (others => '0');
	DOUT <= (others => '0');
	VOUT <= '0';
	Vin_L <= '0';
end if;

end process registers;

--operators instantiation
m1 <= a_1 * sig_2;
m2 <= a_2 * sig_3;
sig_1(11 downto 5) <= x_n(11 downto 5) - m1(22 downto 16) - m2(22 downto 16); --7 bits truncation
sig_1(4 downto 0) <= x_n(4 downto 0);
m3 <= b_0 * sig_1;
m4 <= sig_2 * b_1;
m5 <= sig_3 * b_2;
y_n(11 downto 5) <= m3(22 downto 16) + m4(22 downto 16) + m5(22 downto 16);	  --7 bits truncation
y_n(4 downto 0) <= (others => '0');

end behaviour;                     


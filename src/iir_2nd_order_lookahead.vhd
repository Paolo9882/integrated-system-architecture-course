library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- IIR filter of the second order with a "direct form 2" architecture
-- Lookahead technique, retiming and pipelining are applied to improve throughput
-- Tcp = Ta + Tm
-- Format of the input data: Q1.11 (fixed-point)
-- External data parallelism: 12
-- Filter order: 2

entity iir_2nd_order_lookahead is
    port (
        DIN, a2, a3, b0, b1, b2, b3 : in std_logic_vector(11 downto 0);
        VIN, RST_n, CLK             : in std_logic;
        DOUT                        : out std_logic_vector(11 downto 0);
        VOUT                        : out std_logic
    );
end iir_2nd_order_lookahead;

architecture behaviour of iir_2nd_order_lookahead is

-- input and output signals
signal x_n, y_n: signed(11 downto 0);
-- signed coefficients (from std_logic_vector to signed)
signal a2_s, a3_s, b0_s, b1_s, b2_s, b3_s: signed(11 downto 0);
-- result from first sum (s1), then delayed versions (s1_r, s1_2r, s1_3r)
signal s1, s1_r, s1_2r, s1_3r: signed(11 downto 0);
-- result from second sum (s2) and delayed version
signal s2, s2_r: signed(6 downto 0);
-- result from third and fourth sum (s3, s4)
signal s3, s4: signed(6 downto 0);
-- result from fifth sum (s5) and delayed version
signal s5, s5_r: signed(6 downto 0);
-- results from multiplications
signal m1, m2, m3, m4, m5, m6: signed(23 downto 0);
-- results from multiplications but truncated to 7 bits
signal m1_tr, m2_tr, m3_tr, m4_tr, m5_tr, m6_tr: signed(6 downto 0);
-- delayed versions of the trucated signals out of M3 and M4
signal m3_tr_r, m4_tr_r: signed(6 downto 0);
-- control signals
signal VIN_r, VIN_2r: std_logic;

begin


-- registers implemented with synchronous process
registers: process(CLK, RST_n)
begin

-- registers with enable signal
if (RST_n = '0') then
    x_n <= (others => '0');
    s1_r <= (others => '0');
    s1_2r <= (others => '0');
    s1_3r <= (others => '0');
    s2_r <= (others => '0');
    s5_r <= (others => '0');
    m3_tr_r <= (others => '0');
    m4_tr_r <= (others => '0');
elsif (rising_edge(CLK)) then
    if (VIN = '1') then
        x_n <= signed(DIN);
    end if;

	if (VIN_r = '1') then
		s1_r <= s1;
        s1_2r <= s1_r;
        s1_3r <= s1_2r;
        s2_r <= s2;
		s5_r <= s5;
        m3_tr_r <= m3_tr;
        m4_tr_r <= m4_tr;
	end if;
end if;

-- registers without enable signal
if (RST_n = '0') then
    DOUT <= (others => '0');
    VIN_r <= '0';
    VIN_2r <= '0';
    VOUT <= '0';
elsif (rising_edge(CLK)) then
	DOUT <= std_logic_vector(y_n);
	VIN_r <= VIN;
	VIN_2r <= VIN_r;
    VOUT <= VIN_2r;
end if;

end process registers;

-- conversion of the coefficients (from std_logic_vector to signed)
a2_s <= signed(a2);
a3_s <= signed(a3);
b0_s <= signed(b0);
b1_s <= signed(b1);
b2_s <= signed(b2);
b3_s <= signed(b3);

-- behavioral additions
s1(11 downto 5) <= x_n(11 downto 5) + s2_r;
s1(4 downto 0) <= x_n(4 downto 0);
s2 <= m1_tr + m2_tr;
s3 <= m3_tr_r + s4;
s4 <= m4_tr_r + s5_r;
s5 <= m5_tr + m6_tr;


-- behavioral multiplications
m1 <= s1_r * a2_s;
m2 <= s1_2r * a3_s;
m3 <= s1 * b0_s;
m4 <= s1_r * b1_s;
m5 <= s1_2r * b2_s;
m6 <= s1_3r * b3_s;

-- truncation of multiplications' results
m1_tr <= m1(22 downto 16);
m2_tr <= m2(22 downto 16);
m3_tr <= m3(22 downto 16);
m4_tr <= m4(22 downto 16);
m5_tr <= m5(22 downto 16);
m6_tr <= m6(22 downto 16);

-- extend result from 7 bits to 12
y_n(11 downto 5) <= s3;
y_n(4 downto 0) <= (others => '0');

end behaviour;

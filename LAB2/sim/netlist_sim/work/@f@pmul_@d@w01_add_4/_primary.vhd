library verilog;
use verilog.vl_types.all;
entity FPmul_DW01_add_4 is
    port(
        A               : in     vl_logic_vector(63 downto 0);
        B               : in     vl_logic_vector(63 downto 0);
        CI              : in     vl_logic;
        SUM             : out    vl_logic_vector(63 downto 0);
        CO              : out    vl_logic;
        clk             : in     vl_logic
    );
end FPmul_DW01_add_4;

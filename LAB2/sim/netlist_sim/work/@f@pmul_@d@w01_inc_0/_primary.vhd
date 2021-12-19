library verilog;
use verilog.vl_types.all;
entity FPmul_DW01_inc_0 is
    port(
        A               : in     vl_logic_vector(24 downto 0);
        SUM             : out    vl_logic_vector(24 downto 0);
        clk             : in     vl_logic
    );
end FPmul_DW01_inc_0;

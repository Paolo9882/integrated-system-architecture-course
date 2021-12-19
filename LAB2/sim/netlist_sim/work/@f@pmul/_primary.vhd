library verilog;
use verilog.vl_types.all;
entity FPmul is
    port(
        FP_A            : in     vl_logic_vector(31 downto 0);
        FP_B            : in     vl_logic_vector(31 downto 0);
        clk             : in     vl_logic;
        FP_Z            : out    vl_logic_vector(31 downto 0)
    );
end FPmul;

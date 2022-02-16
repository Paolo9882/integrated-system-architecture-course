library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity alu is
    port (
        -- inputs on 32 bits
        op_A     : in std_logic_vector(31 downto 0);
        op_B     : in std_logic_vector(31 downto 0);
        -- selection bits for the operation
        alu_op   : in std_logic_vector(2 downto 0);
        -- previous result computed by the ALU
        ex_mem_result : in std_logic_vector(31 downto 0);
        -- output on 32 bits
        result   : out std_logic_vector(31 downto 0);
        -- zero flag
        zero     : out std_logic
    );
end entity;

architecture Behavioral of alu is
    signal op_A_signed   : signed(31 downto 0);
    signal op_B_signed   : signed(31 downto 0);
    signal result_signed : signed(31 downto 0);
    signal ex_mem_result_signed : signed (31 downto 0);

begin

    -- cast the inputs to signed data
    op_A_signed <= signed(op_A);
    op_B_signed <= signed(op_B);

    -- cast the output to std_logic_vector
    result <= std_logic_vector(result_signed);

    -- cast the previous result to signed
    ex_mem_result_signed <= signed(ex_mem_result);

    -- ALU process for the arithmetic/logic operations
    PROC_ALU: process(op_A_signed, op_B_signed, ex_mem_result_signed, alu_op)
    begin
        case alu_op is
            -- addition
            when "000" =>
                result_signed <= op_A_signed + op_B_signed;
            -- left shift operation
            when "001" =>
                result_signed <= shift_right(op_A_signed, to_integer('0' & op_B_signed(4 downto 0)));
            -- store if less than operation
            when "010" =>
                if (op_A_signed < op_B_signed) then
                    -- store "000...0001"
                    result_signed(0) <= '1';
                    result_signed(31 downto 1) <= (others => '0');
                else
                    -- store "000...0000"
                    result_signed <= (others => '0');
                end if;
            -- bitwise and operation
            when "011" =>
                result_signed <= op_A_signed and op_B_signed;
            -- bitwise xor operation
            when "100" =>
                result_signed <= op_A_signed xor op_B_signed;
            -- if opcode is not one of the listed ones, do nothing
            when others =>
            -- in this case, clear the result (we can do better from a power point of
            -- view by retaining the previous result and avoiding switching)
                result_signed <= ex_mem_result_signed;
        end case;
    end process;

    -- generation of the zero flag
    PROC_FLAGS: process(result_signed)
    begin
        if (result_signed = to_signed(0, 32)) then
            zero <= '1';
        else
            zero <= '0';
        end if;
    end process;

end architecture Behavioral;

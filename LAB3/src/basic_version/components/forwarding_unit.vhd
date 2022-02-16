library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity forwarding_unit is
    port (
        -- addresses of the operands
        id_ex_rs1        : in std_logic_vector(4 downto 0);
        id_ex_rs2        : in std_logic_vector(4 downto 0);
        -- address of the destination from previous instruction
        ex_mem_rd        : in std_logic_vector(4 downto 0);
        -- address of the destination from two instructions ago
        mem_wb_rd        : in std_logic_vector(4 downto 0);
        -- signal that tells if the previous instruction needed to write on the register file
        ex_mem_reg_write : in std_logic;
        -- signal that tells if the other previous instruction needed to write on the register file
        mem_wb_reg_write : in std_logic;
        -- output of the forwarding unit (they drive the mux of the execution stage)
        fw_a, fw_b       : out std_logic_vector(1 downto 0)
    );
end entity;

architecture Behavioral of forwarding_unit is
-- this is the address of the register x0 which is always set to zero (no write
-- operations are allowed on this register)
constant x0_address : std_logic_vector := "00000";

begin
    -- this process is used to understand if forwarding is needed on the upper mux
    -- of the execution stage (the input of the alu is selected between: data read
    -- from the register file, data coming from the output of the ALU after the pipe register,
    -- or data coming from the output of the ALU after the EX/MEM and MEM/WB pipe registers)
    PROC_FW_A: process(ex_mem_reg_write, mem_wb_reg_write, ex_mem_rd, mem_wb_rd, id_ex_rs1)
    begin
        -- if the previous destination address is different from x0
        -- AND the previous destination address is equal the rs1 source address,
        -- then a data hazard is detected (long forwarding)
        if (ex_mem_reg_write = '1' and (ex_mem_rd /= x0_address) and
        (ex_mem_rd = id_ex_rs1)) then
            -- steer the upper mux of the ALU to use the ALU result from EX/MEM register
            fw_a <= "01";
        -- if the destination address of two instructions ago is different than zero
        -- AND the destination address of two instructions ago is equal to the rs1 source
        -- address (but, AT THE SAME TIME, the previous destination address is different from
        -- the rs1 source) then a short forwarding is needed
        elsif (mem_wb_reg_write = '1' and (mem_wb_rd /= x0_address) and
        (mem_wb_rd = id_ex_rs1) and (ex_mem_reg_write = '0' or
        ex_mem_rd /= id_ex_rs1)) then
            -- steer the upper mux of the ALU to use the ALU result from MEM/WB register
            fw_a <= "10";
        else
            -- if forwarding is not needed load the instruction from the register file
            fw_a <= "00";
        end if;
    end process;

    -- this process handles forwarding in the lower mux of the execution stage
    -- (the input of the alu is selected between: data read
    -- from the register file, data coming from the output of the ALU after the pipe register,
    -- or data coming from the output of the ALU after the EX/MEM and MEM/WB pipe registers)
    PROC_FW_B: process(ex_mem_reg_write, mem_wb_reg_write, ex_mem_rd, mem_wb_rd, id_ex_rs2)
    begin
        -- the code is similar to the one of the previous process, here we check rs2 instead
        if (ex_mem_reg_write = '1' and (ex_mem_rd /= x0_address) and
        (ex_mem_rd = id_ex_rs2)) then
            fw_b <= "01";
        elsif (mem_wb_reg_write = '1' and (mem_wb_rd /= x0_address) and
        (mem_wb_rd = id_ex_rs2) and (ex_mem_reg_write = '0' or
        ex_mem_rd /= id_ex_rs2)) then
            fw_b <= "10";
        else
            fw_b <= "00";
        end if;
    end process;
end architecture Behavioral;

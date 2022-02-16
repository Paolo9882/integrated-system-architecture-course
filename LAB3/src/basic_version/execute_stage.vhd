library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity execute_stage is
    port (
        -- inputs from register file
        data_read_1 : in std_logic_vector(31 downto 0);
        data_read_2 : in std_logic_vector(31 downto 0);
        -- result coming from EX/MEM pipe register
        result_mem  : in std_logic_vector(31 downto 0);
        -- result coming from MEM/WB pipe register
        result_wb   : in std_logic_vector(31 downto 0);
        -- immediate coming from the immediate generation unit
        immediate   : in std_logic_vector(31 downto 0);

        -- addresses of the operands
        id_ex_rs1   : in std_logic_vector(4 downto 0);
        id_ex_rs2   : in std_logic_vector(4 downto 0);
        -- address of the destination from previous instruction
        ex_mem_rd   : in std_logic_vector(4 downto 0);
        -- address of the destination from two instructions ago
        mem_wb_rd   : in std_logic_vector(4 downto 0);
        -- address of the destination from current instruction
        id_ex_rd    : in std_logic_vector(4 downto 0);

        -- alu operation that is needed
        alu_op      : in std_logic_vector(2 downto 0);

        -- signal that tells if the other previous instruction needed to write on the register file
        mem_wb_reg_write : in std_logic;
        -- signal that tells if the previous instruction needed to write on the register file
        ex_mem_reg_write : in std_logic;
        -- signal that tell if the current instruction needs to write on the register file
        id_ex_wb  : in std_logic_vector(1 downto 0);
        -- signal that tells if one of the ALU inputs is an immediate
        immediate_src    : in std_logic;
        -- pipelined control for memory operation
        id_ex_mem        : in std_logic_vector(1 downto 0);

        -- zero flag from the alu
        zero       : out std_logic;
        -- destination register for current operation is passed to the MEM stage
        id_ex_rd_out : out std_logic_vector(4 downto 0);
        -- write register file signal for current operation is passed to MEM stage
        id_ex_wb_out : out std_logic_vector(1 downto 0);
        -- pipelined control for memory operation
        id_ex_mem_out : out std_logic_vector(1 downto 0);
        -- output from the ALU on 32 bits
        result     : out std_logic_vector(31 downto 0);
        -- lower output from the register file (pointed by rs2) is passed to next stage (for STORE instruction)
        data_store : out std_logic_vector(31 downto 0)

    );
end entity;

architecture Structural of execute_stage is

    component alu is
        port (
            op_A     : in std_logic_vector(31 downto 0);
            op_B     : in std_logic_vector(31 downto 0);
            alu_op   : in std_logic_vector(2 downto 0);
            ex_mem_result : in std_logic_vector(31 downto 0);
            result   : out std_logic_vector(31 downto 0);
            zero     : out std_logic
        );
    end component;

    component forwarding_unit is
        port (
            id_ex_rs1        : in std_logic_vector(4 downto 0);
            id_ex_rs2        : in std_logic_vector(4 downto 0);
            ex_mem_rd        : in std_logic_vector(4 downto 0);
            mem_wb_rd        : in std_logic_vector(4 downto 0);
            mem_wb_reg_write : in std_logic;
            ex_mem_reg_write : in std_logic;
            fw_a, fw_b       : out std_logic_vector(1 downto 0)
        );
    end component;

    signal upper_mux_out     : std_logic_vector(31 downto 0);
    signal lower_mux_out     : std_logic_vector(31 downto 0);
    signal immediate_mux_out : std_logic_vector(31 downto 0);

    signal upper_mux_sel : std_logic_vector(1 downto 0);
    signal lower_mux_sel : std_logic_vector(1 downto 0);

    signal fw_a, fw_b    : std_logic_vector(1 downto 0);

begin
    -- the upper mux selection signal is coming directly from forwarding unit
    upper_mux_sel <= fw_a;
    UPPER_MUX: process(data_read_1, result_mem, result_wb, upper_mux_sel)
    begin
        case upper_mux_sel is
            when "00" => upper_mux_out <= data_read_1;
            when "01" => upper_mux_out <= result_mem;
            when others => upper_mux_out <= result_wb;
        end case;
    end process;

    -- the lower mux selection signal is decided by the forwarding unit and by
    -- the control unit in case it is an immediate
    lower_mux_sel <= fw_b;
    LOWER_MUX: process(data_read_2, result_mem, result_wb, lower_mux_sel)
    begin
        case lower_mux_sel is
            when "00" =>
                lower_mux_out <= data_read_2;
            when "01" =>
                lower_mux_out <= result_mem;
            when others =>
                lower_mux_out <= result_wb;
        end case;
    end process;

    data_store <= lower_mux_out;

    IMMEDIATE_MUX: process(lower_mux_out, immediate, immediate_src)
    begin
        case immediate_src is
            when '0' => immediate_mux_out <= lower_mux_out;
            when others => immediate_mux_out <= immediate;
        end case;
    end process;

    --signals that need to be forwarded to the MEM stage
    id_ex_rd_out <= id_ex_rd;
    id_ex_wb_out <= id_ex_wb;
    id_ex_mem_out <= id_ex_mem;

    FW_UNIT: forwarding_unit port map (id_ex_rs1 => id_ex_rs1, id_ex_rs2 => id_ex_rs2,
            ex_mem_rd => ex_mem_rd, mem_wb_rd => mem_wb_rd, mem_wb_reg_write => mem_wb_reg_write,
            ex_mem_reg_write => ex_mem_reg_write, fw_a => fw_a, fw_b => fw_b);

    COMP_ALU: alu port map (op_A => upper_mux_out, op_B => immediate_mux_out, alu_op => alu_op,
            result => result, zero => zero, ex_mem_result => result_mem);
end architecture Structural;

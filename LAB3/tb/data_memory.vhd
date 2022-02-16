library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity data_memory is
    port (
        MAR  : in std_logic_vector(31 downto 0);
        MDRW : in std_logic_vector(31 downto 0);
        RW_n : in std_logic;
        CS      : in std_logic;
        CLK     : in std_logic;
        RST_n   : in std_logic;
        DUMP_MEM : in std_logic;
        START : in std_logic;
        FLASHED : out std_logic;
        MDRR : out std_logic_vector(31 downto 0)
    );
end data_memory;

architecture beh of data_memory is
    -- each word is 32 bits wide
    constant memory_width : integer := 32;
    -- number of words in the memory
    constant memory_depth : integer := 1024;
    -- to simulate the memory segments specify the virtual address that corresponds to
    -- the first address (0x00000000) in memory
    constant data_segment_offset : integer := 16#00002000# / 16#4#;
    -- the memory array is 256 words x 32 bit
    type memory_array is array (0 to memory_depth-1) of std_logic_vector(memory_width-1 downto 0);
    -- create DATA_MEMORY (instance of memory array) and initialize to '0'
    signal DATA_MEMORY : memory_array := (others=>(others=>'0'));
    -- signal that is used to enable the use of the memory only after it has been flashed
    signal flashed_i : std_logic := '0';

begin

    FLASHED <= flashed_i;

    READ_WRITE_FLASH_PROCESS: process(CLK, RST_n, CS, RW_n, START)
    file fp: text open read_mode is "./io/data_memory_init.txt";
    variable ptr : line;
    variable val : std_logic_vector(31 downto 0);
    -- flag that is used to check if the memory has already been flashed with the code or not
    variable not_flashed_yet : boolean := true;
    variable i : integer range 0 to memory_depth-1;
    begin
        if (flashed_i = '1') then
            if (CS = '1' and (to_integer(unsigned(MAR(31 downto 2))) >= data_segment_offset)) then
                -- in reading and writing operations, offset is subtracted from the address
                -- to obtain the real address from the virtual address (obtained from processor)
                if (RW_n = '1') then -- read from data memory
                    MDRR <= DATA_MEMORY(to_integer(unsigned(MAR(31 downto 2))) - data_segment_offset);
                else -- if en_MDRW is '1' then write to memory
                    if (RST_n = '1') then
                        if (rising_edge(CLK)) then -- write to memory at clock edges
                            DATA_MEMORY(to_integer(unsigned(MAR(31 downto 2)))-data_segment_offset) <= MDRW;
                        end if;
                    else
                        MDRR <= (others => '0');
                    end if;
                end if;
            else
                MDRR <= (others => '0');
            end if;
        else
            MDRR <= (others => '0');
            if (rising_edge(START)) then
                if not_flashed_yet then -- if the memory is not flashed yet and START = '1'
                    while (not(endfile(fp)) and i < memory_depth-1) loop
                        readline(fp, ptr);
                        read(ptr, val);
                        -- write the memory the read instruction
                        DATA_MEMORY(i) <= val;
                        i := i + 1;
                    end loop;

                    -- set flashed to '1' and set the flag to false so that the instruction
                    -- memory cannot be written another time
                    not_flashed_yet := false;
                    flashed_i <= '1';
                end if;
            end if;
        end if;
    end process;

    DUMP_MEM_PROCESS: process(DUMP_MEM)
        file data_out : text open WRITE_MODE is "./io/data_memory_dump.txt";
        variable line_out : line;
    begin
        -- if the DUMP MEM signal is set to '1' then all the memory is read and
        -- the content is written to a file
        if (rising_edge(DUMP_MEM)) then
            for i in 0 to memory_depth-1 loop
                write(line_out, DATA_MEMORY(i));
                writeline(data_out, line_out);
            end loop;
        end if;
    end process;
end beh;

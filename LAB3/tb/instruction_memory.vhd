library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

entity instruction_memory is
    port(
	CLK: in std_logic;
	RST_n: in std_logic;
        START: in std_logic;
        PC: in std_logic_vector(31 downto 0);
        IR: out std_logic_vector(31 downto 0);
        FLASHED : out std_logic
    );
end instruction_memory;

architecture beh of instruction_memory is
    -- the words are 32 bits wide
    constant memory_width : integer := 32;
    -- number of words in memory
    constant memory_depth : integer := 256;
    -- to simulate memory segments (actually .text segments starts from 0x0 but this
    -- constant can be tuned in case it is needed)
    constant text_segment_offset : integer := 16#00000000#;
    -- the memory array is 256 words x 32 bit
    type memory_array is array (0 to memory_depth-1) of std_logic_vector(memory_width-1 downto 0);
    -- create INSTRUCTION_MEMORY (instance of memory array) and initialize to '0'
    signal INSTRUCTION_MEMORY : memory_array := (others=>(others=>'0'));
    -- use for addressing just 30 bits (discard the last 2 bits)
    signal instruction_address : std_logic_vector(29 downto 0);

    signal flashed_i : std_logic := '0';

begin

    FLASHED <= flashed_i;

    FLASH_IM: process(START)
        file fp: text open read_mode is "io/program.s";
        variable ptr : line;
        variable val : std_logic_vector(31 downto 0);
        -- flag that is used to check if the memory has already been flashed with the code or not
        variable not_flashed_yet : boolean := true;
        variable i : integer range 0 to memory_depth-1;
    begin
        if (rising_edge(START)) then
            if not_flashed_yet then -- if the memory is not flashed yet and START = '1'
                while (not(endfile(fp))) loop
                    readline(fp, ptr);
                    read(ptr, val);
                    -- write the memory the read instruction
                    INSTRUCTION_MEMORY(i) <= val;
                    i := i + 1;
                end loop;

                -- set flashed to '1' and set the flag to false so that the instruction
                -- memory cannot be written another time
                not_flashed_yet := false;
                flashed_i <= '1';
            end if;
        end if;
    end process;

	instruction_address <= PC(31 downto 2);

	READ_MEM: process(CLK, RST_n)
	begin
	if (RST_n = '1') then
		if(falling_edge(CLK)) then
    			IR <= INSTRUCTION_MEMORY(to_integer(unsigned(instruction_address)) - text_segment_offset);
		end if;
	else
		IR <= (others => '0');
	end if;
	end process;

end beh;

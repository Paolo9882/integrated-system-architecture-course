 -- INSTRUCTION DECODE STAGE
-- the clock signal is used only for the writing operation on the register file

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity decode_stage is
	generic(
		DATA_WIDTH		: integer := 32;
		PARALLELISM		: integer := 5 -- number of registers in the register file
	);
	port(
		-- suffix indicates from which stage the signals arrive
		INSTRUCTION_IF	: in  std_logic_vector(DATA_WIDTH-1 downto 0);
		JUMP_PC_IF		: in  std_logic_vector(DATA_WIDTH-1 downto 0);
		REG_WRITE_WB	: in  std_logic_vector(PARALLELISM-1 downto 0); --addres arriving from WB stage
		DATA_WRITE_WB	: in  std_logic_vector(DATA_WIDTH-1 downto 0); 	--data arriving from WB stage
		EN_W_WB 		: in  std_logic; 								--write enable of the register file arriving from WB stage
		REG_DEST_EX		: in  std_logic_vector(PARALLELISM-1 downto 0); --address arriving from EX stage
																									--used to detect data hazards and by forwarding unit
		REG_DEST_MEM	: in  std_logic_vector(PARALLELISM-1 downto 0); --address arriving from MEM stage
																									-- used by forwarding unit
		MEM_EX			: in  std_logic_vector(1 downto 0); 			--signal provided by control that propagate through stages (from EX stage)
																			--MEM_EX(0) is the CS of the memory ('1' means an access to the memory)
																			--MEM_EX(1) is R_Wn of the memory ('1' means read operation, LW, '0' means SW)
		MEM_MEM			: in  std_logic_vector(1 downto 0); 			--signal provided by control that propagate through stages (from MEM stage)
																			--MEM_MEM(0) is the CS of the memory ('1' means an access to the memory)
																			--MEM_MEM(1) is R_Wn of the memory ('1' means read operation, LW, '0' means SW)
		WB_MEM			: in std_logic;
		WB_EX			: in std_logic;
		CLK				: in  std_logic;
		RST_n			: in  std_logic;

		DATA_ALU_EX	    : in std_logic_vector(DATA_WIDTH-1 downto 0);
		DATA_ALU_MEM	: in std_logic_vector(DATA_WIDTH-1 downto 0);
		DATA_MEM_MEM	: in std_logic_vector(DATA_WIDTH-1 downto 0);

		-- suffix indicates where signals go
		EN_PC_IF 		: out std_logic; 								--signal used to disable the PC in case of hazard, '0' when PC must stop
		EN_PIPE_IF		: out std_logic; 								--signal that disables the pipe between IF and ID stages in case of hazards
		JUMP_ADDRESS_IF	: out std_logic_vector(DATA_WIDTH-1 downto 0); 	--new address of the program counter
		TURN_MUX_IF		: out std_logic; 								--signal that turns the mux in case of jump or branch
		DATA_READ1_EX	: out std_logic_vector(DATA_WIDTH-1 downto 0);	--Data1 going to EX stage
		DATA_READ2_EX	: out std_logic_vector(DATA_WIDTH-1 downto 0);	--Data2 going to EX stage
		IMMEDIATE_EX	: out std_logic_vector(DATA_WIDTH-1 downto 0);	--immediate going to the EX stage
		EX_CONTROL_EX	: out std_logic_vector(3 downto 0); 			--control signal for the execution stage:
																			--EX(3) = '0' => REG_READ2, EX(3) = '1' => IMMEDIATE
																			--EX(2 DOWNTO 0) => "000" => ADD,
																			--"001" => SHIFT,
																			--"010" => LESS THEN,
																			--"011" AND,
																			--"100" => XOR,
																			--OTHERS => NOTHING
		MEM_CONTROL_EX 	: out std_logic_vector(1 downto 0); 			--control signal of MEM stage sent to the execution stage
																			--MEM_CONTROL_EX(0) is the CS of the memory ('1' means an access to the memory)
																			--MEM_CONTROL_EX(1) is R_Wn of the memory ('1' means read operation, LW, '0' means SW)
		WB_CONTROL_EX 	: out std_logic_vector(1 downto 0); 			--control signal of WB stage sent to the execution stage
																			--WB(1) = '1' => WB on register file
																			--WB(0) = '0' => result from the alu
																			--WB(0) = '1' => result from the data memory
		REG_READ1_EX	: out std_logic_vector(4 downto 0); 			--signal going from control to the execute stage
		REG_READ2_EX	: out std_logic_vector(4 downto 0); 			--signal going from control to the execute stage
		REG_DEST_EX_OUT	: out std_logic_vector(4 downto 0) 				--signal going from control to the execute stage
	);
end decode_stage;


architecture structure of decode_stage is

signal COMP : std_logic; --signal from comparator to control
signal EN_NEXT_OP : std_logic; --signal from HDU to the mux
signal IMM_TYPE : std_logic_vector(2 downto 0); --signal from control to immediate_generator
signal IMMEDIATE : std_logic_vector(DATA_WIDTH-1 downto 0); --immediate generated from immediate generator
signal REG_READ1, REG_READ2, REG_DEST : std_logic_vector(PARALLELISM-1 downto 0); --addresses coming from control
signal DATA_READ1, DATA_READ2 : std_logic_vector(DATA_WIDTH-1 downto 0); --data read from the register file
signal EX_MUX : std_logic_vector(3 downto 0);
signal MEM_MUX : std_logic_vector(1 downto 0);
signal WB_MUX : std_logic_vector(1 downto 0);
signal FW_A, FW_B : std_logic_vector(1 downto 0);
signal DATA_MEM : std_logic_vector(31 downto 0);
signal MUX_OUT_COMP1 : std_logic_vector(31 downto 0);
signal MUX_OUT_COMP2 : std_logic_vector(31 downto 0);
--signals for register file bypassing so that it always work on the rising edge
signal REG_FILE_BYPASS_UPPER: std_logic;
signal REG_FILE_BYPASS_LOWER: std_logic;
signal REG_FILE_BYPASS_UPPER_OUT: std_logic_vector(31 downto 0);
signal REG_FILE_BYPASS_LOWER_OUT: std_logic_vector(31 downto 0);


component adder is
	generic(DATA_WIDTH	: integer);
	port(
		INPUT1		: in  std_logic_vector(DATA_WIDTH-1 downto 0);
		INPUT2		: in  std_logic_vector(DATA_WIDTH-1 downto 0);
		OUTPUT		: out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end component;

component comparator is
	GENERIC(DATA_WIDTH : integer);
	PORT(
		INPUT1		: IN std_logic_vector (DATA_WIDTH-1 DOWNTO 0); --input 1
		INPUT2		: IN std_logic_vector (DATA_WIDTH-1 DOWNTO 0); --input 2
		EN			: IN std_logic; -- enable is always '1'
		OUTPUT		: OUT std_logic
	);
end component;

component hazard_mux is
	GENERIC(ADD_WIDTH : integer);
	PORT(
		REG_READ1		: IN  std_logic_vector (ADD_WIDTH-1 DOWNTO 0);
		REG_READ2		: IN  std_logic_vector (ADD_WIDTH-1 DOWNTO 0);
		REG_DEST		: IN  std_logic_vector (ADD_WIDTH-1 DOWNTO 0);
		EX_MUX			: IN  std_logic_vector (3 DOWNTO 0);
		MEM_MUX			: IN  std_logic_vector(1 downto 0);
		WB_MUX			: IN  std_logic_vector (1 downto 0);
		SEL				: IN  std_logic;
		REG_READ1_EX	: OUT std_logic_vector (ADD_WIDTH-1 DOWNTO 0);
		REG_READ2_EX	: OUT std_logic_vector (ADD_WIDTH-1 DOWNTO 0);
		REG_DEST_EX		: OUT std_logic_vector (ADD_WIDTH-1 DOWNTO 0);
		EX_CONTROL		: OUT std_logic_vector (3 DOWNTO 0);
		MEM_CONTROL 	: OUT std_logic_vector(1 downto 0);
		WB_CONTROL 		: OUT std_logic_vector (1 downto 0)
	);
end component;

component HDU is
	GENERIC(ADD_WIDTH : integer);
	PORT(
		REG_READ1		: IN  std_logic_vector (ADD_WIDTH-1 DOWNTO 0); --address of register
		REG_READ2		: IN  std_logic_vector (ADD_WIDTH-1 DOWNTO 0); --address of register
		REG_DEST_PREV	: IN  std_logic_vector (ADD_WIDTH-1 DOWNTO 0); --address of register
		MEM_PREV		: IN  std_logic_vector(1 downto 0);
		EN_PC			: OUT std_logic;
		EN_PIPE			: OUT std_logic;
		EN_NEXT_OP		: OUT std_logic
	);
end component;

component immediate_generator is
	generic(DATA_WIDTH	: integer);
	port(
		INSTRUCTION	: in  std_logic_vector(DATA_WIDTH-1 downto 0);
		IMM_TYPE	: in  std_logic_vector(2 DOWNTO 0);
		IMMEDIATE	: out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end component;

component register_file is
	generic(DATA_WIDTH	: integer;
		PARALLELISM		: integer);
	port(
		REG_READ1	: in  std_logic_vector(PARALLELISM-1 downto 0);
		REG_READ2	: in  std_logic_vector(PARALLELISM-1 downto 0);
		REG_WRITE	: in  std_logic_vector(PARALLELISM-1 downto 0);
		DATA_WRITE	: in  std_logic_vector(DATA_WIDTH-1 downto 0);
		EN_W		: in  std_logic;
		RST_n		: in  std_logic;
		CLK         : in  std_logic;
		DATA_READ1	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		DATA_READ2	: out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end component;

component forwarding_unit is
    port (
        id_ex_rs1        : in std_logic_vector(4 downto 0);
        id_ex_rs2        : in std_logic_vector(4 downto 0);
        ex_mem_rd        : in std_logic_vector(4 downto 0);
        mem_wb_rd        : in std_logic_vector(4 downto 0);
        ex_mem_reg_write : in std_logic;
        mem_wb_reg_write : in std_logic;
        fw_a, fw_b       : out std_logic_vector(1 downto 0)
    );
end component;

component control is
	generic(DATA_WIDTH 	: integer;
		ADD_WIDTH 		: integer);
	port(
		--input signals
		INSTRUCTION	: IN  std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
		OPERAND1	: IN  std_logic_vector(DATA_WIDTH-1 DOWNTO 0); --operands coming from the register file
		OPERAND2	: IN  std_logic_vector(DATA_WIDTH-1 DOWNTO 0); --operands coming from the register file
		PC			: IN  std_logic_vector(DATA_WIDTH-1 DOWNTO 0); --program counter coming from the IF stage
		COMP		: IN  std_logic; --signal coming from the comparator, that is always enabled

		--IF signals
		TURN_MUX	: OUT std_logic; --signal used for jump and branch, '1' to jump
		--ID signals
		IMM_TYPE	: OUT std_logic_vector (2 DOWNTO 0); --sent to immediate_generator
		--EX signals
		EX			: OUT std_logic_vector (3 DOWNTO 0);--EX(3) = '1' => REG_READ2, EX(3) = '0' => IMMEDIATE
														--EX(2 DOWNTO 0) => "000" => ADD,
																		--"001" => SHIFT,
																		--"010" => LESS THEN,
																		--"011" AND,
																		--"100" => XOR,
																		--OTHERS => NOTHING
		--MEM signals
		MEM			: OUT std_logic_vector(1 downto 0); --MEM(0) is the CS of the memory ('1' means an access to the memory)
														--MEM(1) is R_Wn of the memory ('1' means read operation, LW, '0' means SW)
		--WB signals
		WB			: OUT std_logic_vector(1 DOWNTO 0); --WB(1) = '1' => WB on register file
														--WB(0) = '0' => result from the alu
														--WB(0) = '1' => result from the data memory
		--signals to the EX stage
		--register addresses are "00000" if the register is not used, to avoid fake hazards
		REG_READ1	: OUT std_logic_vector(ADD_WIDTH-1 DOWNTO 0);
		REG_READ2	: OUT std_logic_vector(ADD_WIDTH-1 DOWNTO 0);
		REG_DEST	: OUT std_logic_vector(ADD_WIDTH-1 DOWNTO 0);
		--in case of JAL and AUIPC the data are not coming from the register file
		DATA1		: OUT std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
		DATA2		: OUT std_logic_vector(DATA_WIDTH-1 DOWNTO 0)
	);
end component;

begin

reg_file : register_file
	generic map(
		DATA_WIDTH => DATA_WIDTH,
		PARALLELISM => PARALLELISM)
	port map(
		REG_READ1 	=> INSTRUCTION_IF(19 downto 15),
		REG_READ2 	=> INSTRUCTION_IF(24 downto 20),
		REG_WRITE 	=> REG_WRITE_WB,
		DATA_WRITE 	=> DATA_WRITE_WB,
		EN_W 		=> EN_W_WB,
		RST_n		=> RST_n,
		CLK 		=> CLK,
		DATA_READ1 	=> DATA_READ1,
		DATA_READ2 	=> DATA_READ2);

--multiplexer for bypassing the register file in case the operand 1 is the one coming from the WB stage
bypass_upper_mux: process(REG_FILE_BYPASS_UPPER, DATA_READ1, DATA_WRITE_WB)
begin
	case REG_FILE_BYPASS_UPPER is
		when '0' =>
			REG_FILE_BYPASS_UPPER_OUT <= DATA_READ1;
		when others =>
			REG_FILE_BYPASS_UPPER_OUT <= DATA_WRITE_WB;
	end case;
end process;

--multiplexer for bypassing the register file in case the operand 2 is the one coming from the WB stage
bypass_lower_mux: process(REG_FILE_BYPASS_LOWER, DATA_READ2, DATA_WRITE_WB)
begin
	case REG_FILE_BYPASS_LOWER is
		when '0' =>
			REG_FILE_BYPASS_LOWER_OUT <= DATA_READ2;
		when others =>
			REG_FILE_BYPASS_LOWER_OUT <= DATA_WRITE_WB;
	end case;
end process;

--comparison of the address of the writeback stage with the operand of the current operand 1
bypass_signal_upper: process(REG_READ1, REG_WRITE_WB)
begin
	if (REG_READ1 = REG_WRITE_WB and REG_READ1 /= "00000") then
		REG_FILE_BYPASS_UPPER <= '1';
	else
		REG_FILE_BYPASS_UPPER <= '0';
	end if;
end process;

--comparison of the address of the writeback stage with the operand of the current operand 2
bypass_signal_lower: process(REG_READ2, REG_WRITE_WB)
begin
	if (REG_READ2 = REG_WRITE_WB and REG_READ2 /= "00000") then
		REG_FILE_BYPASS_LOWER <= '1';
	else
		REG_FILE_BYPASS_LOWER <= '0';
	end if;
end process;

data_comparator : comparator
	generic map(
		DATA_WIDTH => DATA_WIDTH)
	port map(
		INPUT1 	=> MUX_OUT_COMP1,
		INPUT2 	=> MUX_OUT_COMP2,
		EN		=> '1',
		OUTPUT 	=> COMP);

immediate_gen : immediate_generator
	generic map(
		DATA_WIDTH => DATA_WIDTH)
	port map(
		INSTRUCTION => INSTRUCTION_IF,
		IMM_TYPE	=> IMM_TYPE,
		IMMEDIATE	=> IMMEDIATE);

add : adder
	generic map(
		DATA_WIDTH => DATA_WIDTH)
	port map(
		INPUT1 => IMMEDIATE,
		INPUT2 => JUMP_PC_IF,
		OUTPUT => JUMP_ADDRESS_IF);

detection_unit : HDU
	generic map(
		ADD_WIDTH => PARALLELISM)
	port map(
		REG_READ1 		=> REG_READ1,
		REG_READ2		=> REG_READ2,
		REG_DEST_PREV	=> REG_DEST_EX,
		MEM_PREV		=> MEM_EX,
		EN_PC			=> EN_PC_IF,
		EN_PIPE			=> EN_PIPE_IF,
		EN_NEXT_OP		=> EN_NEXT_OP);

MUX : hazard_mux
	generic map(
		ADD_WIDTH => PARALLELISM)
	port map(
		REG_READ1		=> REG_READ1,
		REG_READ2		=> REG_READ2,
		REG_DEST		=> REG_DEST,
		EX_MUX			=> EX_MUX,
		MEM_MUX			=> MEM_MUX,
		WB_MUX			=> WB_MUX,
		SEL				=> EN_NEXT_OP,
		REG_READ1_EX	=> REG_READ1_EX,
		REG_READ2_EX	=> REG_READ2_EX,
		REG_DEST_EX		=> REG_DEST_EX_OUT,
		EX_CONTROL		=> EX_CONTROL_EX,
		MEM_CONTROL 	=> MEM_CONTROL_EX,
		WB_CONTROL 		=> WB_CONTROL_EX);

CU : control
	generic map(
		DATA_WIDTH 	=> DATA_WIDTH,
		ADD_WIDTH 	=> PARALLELISM)
	port map(
		INSTRUCTION	=> INSTRUCTION_IF,
		OPERAND1	=> REG_FILE_BYPASS_UPPER_OUT,
		OPERAND2	=> REG_FILE_BYPASS_LOWER_OUT,
		PC			=> JUMP_PC_IF,
		COMP		=> COMP,

		TURN_MUX	=> TURN_MUX_IF,
		IMM_TYPE	=> IMM_TYPE,
		EX 			=> EX_MUX,
		MEM			=> MEM_MUX,
		WB			=> WB_MUX,
		REG_READ1	=> REG_READ1,
		REG_READ2	=> REG_READ2,
		REG_DEST	=> REG_DEST,
		DATA1		=> DATA_READ1_EX,
		DATA2		=> DATA_READ2_EX);

FW : forwarding_unit
	port map(
		id_ex_rs1 => REG_READ1,
		id_ex_rs2 => REG_READ2,
		ex_mem_rd => REG_DEST_EX,
		mem_wb_rd => REG_DEST_MEM,
		ex_mem_reg_write => WB_EX,
		mem_wb_reg_write => WB_MEM,
		fw_a => FW_A,
		fw_b => FW_B
	);

	UPPER_MUX: process(REG_FILE_BYPASS_UPPER_OUT, DATA_ALU_EX, DATA_MEM, FW_A)
	begin
	    case FW_A is
	        when "00" => MUX_OUT_COMP1 <= REG_FILE_BYPASS_UPPER_OUT;
	        when "01" => MUX_OUT_COMP1 <= DATA_ALU_EX;
	        when others => MUX_OUT_COMP1 <= DATA_MEM;
	    end case;
	end process;

	LOWER_MUX: process(REG_FILE_BYPASS_LOWER_OUT, DATA_ALU_EX, DATA_MEM, FW_B)
	begin
	    case FW_B is
	        when "00" =>
	            MUX_OUT_COMP2 <= REG_FILE_BYPASS_LOWER_OUT;
	        when "01" =>
	            MUX_OUT_COMP2 <= DATA_ALU_EX;
	        when others =>
	            MUX_OUT_COMP2 <= DATA_MEM;
	    end case;
	end process;

	DATA_MUX: process(DATA_ALU_MEM, DATA_MEM_MEM, MEM_MEM)
	begin
		case MEM_MEM is
			when "11" => -- in case of load instruction
				DATA_MEM <= DATA_MEM_MEM;
			when others =>
				DATA_MEM <= DATA_ALU_MEM;
		end case;
	end process;


IMMEDIATE_EX	<= IMMEDIATE;

end structure;


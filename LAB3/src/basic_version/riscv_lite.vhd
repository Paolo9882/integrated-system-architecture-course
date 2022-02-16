library ieee;
use ieee.std_logic_1164.all;

--RISC-V lite processor
entity riscv_lite is
	port(
		clk: in std_logic; --clock
		rst_n: in std_logic; --reset
		IR: in std_logic_vector(31 downto 0); --instruction register
		MDRR: in std_logic_vector(31 downto 0); --memory data register (read)
		PC: out std_logic_vector(31 downto 0); --program counter
		MAR: out std_logic_vector(31 downto 0); --memory address register
		MDRW: out std_logic_vector(31 downto 0); --memory data register (write)
		cs_MDRW: out std_logic; --chip select data memory
		rd_wr_n_MDRW: out std_logic --read/write data memory
	);
end riscv_lite;

architecture structural of riscv_lite is

	--components (stages)

	--Fetch stage
	component fetch_stage is
		port(
			PC_addr: in std_logic_vector(31 downto 0); --input program counter current address
			jump_addr: in std_logic_vector(31 downto 0); --jump address
			en_jump: in std_logic; --enable jump condition
			in_instr_from_memory: in std_logic_vector(31 downto 0); --input instruction from instruction memory
			curr_addr: out std_logic_vector(31 downto 0); --output program counter current address
			next_addr: out std_logic_vector(31 downto 0); --program counter next address
			out_instr_from_memory: out std_logic_vector(31 downto 0) --output instruction from instruction memory
		);
	end component;

	--Decode stage
	component decode_stage is
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
	end component;

	--Execute stage
	component execute_stage is
    	port (
        	data_read_1 : in std_logic_vector(31 downto 0); -- inputs from register file
        	data_read_2 : in std_logic_vector(31 downto 0);
        	result_mem  : in std_logic_vector(31 downto 0); -- result coming from EX/MEM pipe register
        	result_wb   : in std_logic_vector(31 downto 0); -- result coming from MEM/WB pipe register
     	   	immediate   : in std_logic_vector(31 downto 0); -- immediate coming from the immediate generation unit
        	id_ex_rs1   : in std_logic_vector(4 downto 0); -- addresses of the operands
        	id_ex_rs2   : in std_logic_vector(4 downto 0);
        	ex_mem_rd   : in std_logic_vector(4 downto 0); -- address of the destination from previous instruction
        	mem_wb_rd   : in std_logic_vector(4 downto 0); -- address of the destination from two instructions ago
        	id_ex_rd    : in std_logic_vector(4 downto 0); -- address of the destination from current instruction
        	alu_op      : in std_logic_vector(2 downto 0); -- alu operation that is needed
        	mem_wb_reg_write : in std_logic; -- signal that tells if the other previous instruction needed to write on the register file
        	ex_mem_reg_write : in std_logic; -- signal that tells if the previous instruction needed to write on the register file
        	id_ex_wb  : in std_logic_vector(1 downto 0); -- signal that tell if the current instruction needs to write on the register file
          	immediate_src    : in std_logic; -- signal that tells if one of the ALU inputs is an immediate
        	id_ex_mem        : in std_logic_vector(1 downto 0); -- pipelined control for memory operation
        	zero       : out std_logic; -- zero flag from the alu
        	id_ex_rd_out : out std_logic_vector(4 downto 0); -- destination register for current operation is passed to the MEM stage
        	id_ex_wb_out : out std_logic_vector(1 downto 0); -- write register file signal for current operation is passed to MEM stage
        	id_ex_mem_out : out std_logic_vector(1 downto 0); -- pipelined control for memory operation
        	result     : out std_logic_vector(31 downto 0); -- output from the ALU on 32 bits
        	data_store : out std_logic_vector(31 downto 0) -- lower output from the register file (pointed by rs2) is passed to next stage (for STORE instruction)
    	);
	end component;

	--Memory stage
	component memory_stage is
		port(
			in_addr: in std_logic_vector(31 downto 0); --input data memory address
			in_data_to_mem: in std_logic_vector(31 downto 0); --input data to data memory
			in_data_from_mem: in std_logic_vector(31 downto 0); --input data from data memory
			out_addr: out std_logic_vector(31 downto 0); --output data memory address
			out_data_to_mem: out std_logic_vector(31 downto 0); --output data to data memory
			out_data_from_mem: out std_logic_vector(31 downto 0) --output data from data memory
		);
	end component;

	--Write Back stage
	component writeback_stage is
		port(
			en_load: in std_logic; --enable load data condition
			result_write: in std_logic_vector(31 downto 0); --computed result
			data_load: in std_logic_vector(31 downto 0); --loaded data
			data_wb: out std_logic_vector(31 downto 0) --data to be written back
		);
	end component;


	--signals

	signal en_PC: std_logic; --enable program counter
	signal PC_in, PC_out: std_logic_vector(31 downto 0); --program counter input and output
	signal jump_addr: std_logic_vector(31 downto 0); --jump address
	signal en_jump: std_logic; --enable jump condition

	signal en_F_D: std_logic; --enable fetch to decode register
	signal F_flush: std_logic; --flush fetch to decode register
	signal F_D_in, F_D_out: std_logic_vector(63 downto 0); --fetch to decode register input and output

	signal D_EX_in, D_EX_out: std_logic_vector(118 downto 0); --decode to execute register input and output

	signal EX_MEM_in, EX_MEM_out: std_logic_vector(72 downto 0); --execute to memory register input and output

	signal MEM_WB_in, MEM_WB_out: std_logic_vector(70 downto 0); --memory to write back register input and output
	signal data_wb: std_logic_vector(31 downto 0); --write back to decode stage data


	begin

	--stages port map

	F: fetch_stage
		port map(
			PC_addr => PC_out,
			jump_addr => jump_addr,
			en_jump => en_jump,
			in_instr_from_memory => IR,
			curr_addr => PC,
			next_addr => PC_in,
			out_instr_from_memory => F_D_in(31 downto 0)
		);

	F_D_in(63 downto 32) <= PC_out;
	F_flush <= en_jump; --flush F_D pipe register when a brunch/jump condition is present

	D: decode_stage
		generic map(
			DATA_WIDTH => 32,
			PARALLELISM	=> 5
		)
		port map(
			INSTRUCTION_IF	=> F_D_out(31 downto 0),
			JUMP_PC_IF => F_D_out(63 downto 32),
			REG_WRITE_WB => MEM_WB_out(4 downto 0),
			DATA_WRITE_WB => data_wb,
			EN_W_WB => MEM_WB_out(70),
			REG_DEST_EX => D_EX_out(4 downto 0),
			REG_DEST_MEM => EX_MEM_out(4 downto 0),
			MEM_EX => D_EX_out(116 downto 115),
			MEM_MEM => EX_MEM_out(70 downto 69),
			DATA_ALU_EX => EX_MEM_in(68 downto 37),
			DATA_ALU_MEM => MEM_WB_in(36 downto 5),
			DATA_MEM_MEM => MEM_WB_in(68 downto 37),
			WB_EX => D_EX_out(118),
			WB_MEM => EX_MEM_out(72),
			CLK => clk,
			RST_n => rst_n,
			EN_PC_IF => en_PC,
			EN_PIPE_IF => en_F_D,
			JUMP_ADDRESS_IF => jump_addr,
			TURN_MUX_IF	=> en_jump,
			DATA_READ1_EX => D_EX_in(110 downto 79),
			DATA_READ2_EX => D_EX_in(78 downto 47),
			IMMEDIATE_EX => D_EX_in(46 downto 15),
			EX_CONTROL_EX => D_EX_in(114 downto 111),
			MEM_CONTROL_EX => D_EX_in(116 downto 115),
			WB_CONTROL_EX => D_EX_in(118 downto 117),
			REG_READ1_EX => D_EX_in(14 downto 10),
			REG_READ2_EX => D_EX_in(9 downto 5),
			REG_DEST_EX_OUT	=> D_EX_in(4 downto 0)
		);

	EX: execute_stage
		port map(
			data_read_1 => D_EX_out(110 downto 79),
        	data_read_2 => D_EX_out(78 downto 47),
        	result_mem => EX_MEM_out(68 downto 37),
        	result_wb => data_wb,
     	   	immediate => D_EX_out(46 downto 15),
        	id_ex_rs1 => D_EX_out(14 downto 10),
        	id_ex_rs2 => D_EX_out(9 downto 5),
        	ex_mem_rd => EX_MEM_out(4 downto 0),
        	mem_wb_rd => MEM_WB_out(4 downto 0),
        	id_ex_rd => D_EX_out(4 downto 0),
        	alu_op => D_EX_out(113 downto 111),
        	mem_wb_reg_write => MEM_WB_out(70),
        	ex_mem_reg_write => EX_MEM_out(72),
			id_ex_wb => D_EX_out(118 downto 117),
        	immediate_src => D_EX_out(114),
			id_ex_mem => D_EX_out(116 downto 115),
        	zero => open,
        	id_ex_rd_out => EX_MEM_in(4 downto 0),
        	id_ex_wb_out => EX_MEM_in(72 downto 71),
        	id_ex_mem_out => EX_MEM_in(70 downto 69),
        	result => EX_MEM_in(68 downto 37),
        	data_store => EX_MEM_in(36 downto 5)
		);

	MEM: memory_stage
		port map(
			in_addr => EX_MEM_out(68 downto 37),
			in_data_to_mem => EX_MEM_out(36 downto 5),
			in_data_from_mem => MDRR,
			out_addr => MAR,
			out_data_to_mem => MDRW,
			out_data_from_mem => MEM_WB_in(68 downto 37)
		);

	MEM_WB_in(70 downto 69) <= EX_MEM_out(72 downto 71);
	cs_MDRW <= EX_MEM_out(70);
	rd_wr_n_MDRW <= EX_MEM_out(69);
	MEM_WB_in(36 downto 5) <= EX_MEM_out(68 downto 37);
	MEM_WB_in(4 downto 0) <= EX_MEM_out(4 downto 0);

	WB: writeback_stage
		port map(
			en_load => MEM_WB_out(69),
			result_write => MEM_WB_out(36 downto 5),
			data_load => MEM_WB_out(68 downto 37),
			data_wb => data_wb
		);


	--pipe registers

	--program counter
	PC_reg: process(clk, rst_n, en_PC)
	begin
	if (rst_n = '1') then
		if (rising_edge(clk) and en_PC = '1') then
			PC_out <= PC_in;
		end if;
	else
		PC_out <= (others => '0');
	end if;
	end process;

	--fetch to decode register
	F_D: process(clk, rst_n, F_flush, en_F_D)
	begin
	if (rst_n = '1') then
		if (rising_edge(clk) and en_F_D = '1') then
			if (F_flush = '0') then
				F_D_out <= F_D_in;
			else
				F_D_out <= (others => '0');
			end if;
		end if;
	else
		F_D_out <= (others => '0');
	end if;
	end process;

	--decode to execute register
	D_EX: process(clk, rst_n)
	begin
	if (rst_n = '1') then
		if rising_edge(clk) then
			D_EX_out <= D_EX_in;
		end if;
	else
		D_EX_out <= (others => '0');
	end if;
	end process;

	--execute to memory register
	EX_MEM: process(clk, rst_n)
	begin
	if (rst_n = '1') then
		if rising_edge(clk) then
			EX_MEM_out <= EX_MEM_in;
		end if;
	else
		EX_MEM_out <= (others => '0');
	end if;
	end process;

	--memory to write back register
	MEM_WB: process(clk, rst_n)
	begin
	if (rst_n = '1') then
		if rising_edge(clk) then
			MEM_WB_out <= MEM_WB_in;
		end if;
	else
		MEM_WB_out <= (others => '0');
	end if;
	end process;


end structural;

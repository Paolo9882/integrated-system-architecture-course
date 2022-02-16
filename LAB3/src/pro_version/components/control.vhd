-- CONTROL of the ID  phase
-- MANCA L'OPERAZIONE ABS

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY control is
	GENERIC(
		DATA_WIDTH 	: integer := 32;
		ADD_WIDTH 	: integer := 5
	);
	PORT(
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
		EX			: OUT std_logic_vector (3 DOWNTO 0);--EX(3) = '0' => REG_READ2, EX(3) = '1' => IMMEDIATE
														--EX(2 DOWNTO 0) => "000" => ADD,
																		--"001" => SHIFT LEFT,
																		--"010" => LESS THEN,
																		--"011" AND,
																		--"100" => XOR,
																		--"101" => ABS
																		--"110" => SHIFT RIGHT,
																		--OTHERS => NOTHING
		--MEM signals
		MEM			: OUT std_logic_vector (1 DOWNTO 0);--MEM(0) is the CS of the memory ('1' means an access to the memory)
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

END control;

ARCHITECTURE behaviour OF control IS

BEGIN

PROCESS(INSTRUCTION, COMP, OPERAND1, OPERAND2, PC)

BEGIN
	-- ADD operation
	IF ( INSTRUCTION(31 downto 25) = "0000000" AND INSTRUCTION(14 downto 12) = "000"  AND INSTRUCTION(6 downto 0) = "0110011" ) THEN
		TURN_MUX 	<= '0';
		IMM_TYPE 	<= "111";
		EX			<= "0000";
		MEM			<= "00";
		WB			<= "10";
		REG_READ1	<= INSTRUCTION(19 DOWNTO 15);
		REG_READ2	<= INSTRUCTION(24 DOWNTO 20);
		REG_DEST	<= INSTRUCTION(11 DOWNTO 7);
		DATA1		<= OPERAND1;
		DATA2		<= OPERAND2;

	-- ADDI operation
	ELSIF ( INSTRUCTION(14 downto 12) = "000" AND INSTRUCTION(6 downto 0) = "0010011" ) THEN
		TURN_MUX 	<= '0';
		IMM_TYPE 	<= "000";
		EX			<= "1000";
		MEM			<= "00";
		WB			<= "10";
		REG_READ1	<= INSTRUCTION(19 DOWNTO 15);
		REG_READ2	<= (others => '0');
		REG_DEST	<= INSTRUCTION(11 DOWNTO 7);
		DATA1		<= OPERAND1;
		DATA2		<= OPERAND2;

	-- AUIPC operation
	ELSIF ( INSTRUCTION(6 downto 0) = "0010111" ) THEN
		TURN_MUX 	<= '0';
		IMM_TYPE 	<= "011";
		EX			<= "1000";
		MEM			<= "00";
		WB			<= "10";
		REG_READ1	<= (others => '0');
		REG_READ2	<= (others => '0');
		REG_DEST	<= INSTRUCTION(11 DOWNTO 7);
		DATA1		<= PC;
		DATA2		<= OPERAND2;

	-- LUI operation
	ELSIF ( INSTRUCTION(6 downto 0) = "0110111" ) THEN
		TURN_MUX 	<= '0';
		IMM_TYPE 	<= "011";
		EX			<= "1000";
		MEM			<= "00";
		WB			<= "10";
		REG_READ1	<= (others => '0');
		REG_READ2	<= (others => '0');
		REG_DEST	<= INSTRUCTION(11 DOWNTO 7);
		DATA1		<= OPERAND1;
		DATA2		<= OPERAND2;

	-- BEQ operation
	ELSIF ( INSTRUCTION(14 downto 12) = "000"  AND INSTRUCTION(6 downto 0) = "1100011" ) THEN
		TURN_MUX 	<= COMP;
		IMM_TYPE 	<= "010";
		EX			<= "0111";
		MEM			<= "00";
		WB			<= "00";
		REG_READ1	<= INSTRUCTION(19 DOWNTO 15);
		REG_READ2	<= INSTRUCTION(24 DOWNTO 20);
		REG_DEST	<= (others => '0');
		DATA1		<= OPERAND1;
		DATA2		<= OPERAND2;

	-- LW operation
	ELSIF ( INSTRUCTION(14 downto 12) = "010"  AND INSTRUCTION(6 downto 0) = "0000011" ) THEN
		TURN_MUX 	<= '0';
		IMM_TYPE 	<= "000";
		EX			<= "1000";
		MEM			<= "11";
		WB			<= "11";
		REG_READ1	<= INSTRUCTION(19 DOWNTO 15);
		REG_READ2	<= (others => '0');
		REG_DEST	<= INSTRUCTION(11 DOWNTO 7);
		DATA1		<= OPERAND1;
		DATA2		<= OPERAND2;

	-- SRAI operation
	ELSIF ( INSTRUCTION(31 downto 25) = "0100000" AND INSTRUCTION(14 downto 12) = "101"  AND INSTRUCTION(6 downto 0) = "0010011" ) THEN
		TURN_MUX 	<= '0';
		IMM_TYPE 	<= "000";
		EX			<= "1001";
		MEM			<= "00";
		WB			<= "10";
		REG_READ1	<= INSTRUCTION(19 DOWNTO 15);
		REG_READ2	<= (others => '0');
		REG_DEST	<= INSTRUCTION(11 DOWNTO 7);
		DATA1		<= OPERAND1;
		DATA2		<= OPERAND2;

	-- SLLI operation
	ELSIF ( INSTRUCTION(31 downto 25) = "0000000" AND INSTRUCTION(14 downto 12) = "001" AND INSTRUCTION(6 downto 0) = "0010011" ) THEN
		TURN_MUX	<= '0';
		IMM_TYPE	<= "000";
		EX			<= "1110";
		MEM			<= "00";
		WB			<= "10";
		REG_READ1 	<= INSTRUCTION(19 DOWNTO 15);
		REG_READ2	<= (others => '0');
		REG_DEST	<= INSTRUCTION(11 DOWNTO 7);
		DATA1		<= OPERAND1;
		DATA2		<= OPERAND2;

	-- ANDI operation
	ELSIF ( INSTRUCTION(14 downto 12) = "111"  AND INSTRUCTION(6 downto 0) = "0010011" ) THEN
		TURN_MUX 	<= '0';
		IMM_TYPE 	<= "000";
		EX			<= "1011";
		MEM			<= "00";
		WB			<= "10";
		REG_READ1	<= INSTRUCTION(19 DOWNTO 15);
		REG_READ2	<= (others => '0');
		REG_DEST	<= INSTRUCTION(11 DOWNTO 7);
		DATA1		<= OPERAND1;
		DATA2		<= OPERAND2;

	-- XOR operation
	ELSIF ( INSTRUCTION(31 downto 25) = "0000000" AND INSTRUCTION(14 downto 12) = "100"  AND INSTRUCTION(6 downto 0) = "0110011" ) THEN
		TURN_MUX 	<= '0';
		IMM_TYPE 	<= "111";
		EX			<= "0100";
		MEM			<= "00";
		WB			<= "10";
		REG_READ1	<= INSTRUCTION(19 DOWNTO 15);
		REG_READ2	<= INSTRUCTION(24 DOWNTO 20);
		REG_DEST	<= INSTRUCTION(11 DOWNTO 7);
		DATA1		<= OPERAND1;
		DATA2		<= OPERAND2;

	-- SLT operation
	ELSIF ( INSTRUCTION(31 downto 25) = "0000000" AND INSTRUCTION(14 downto 12) = "010"  AND INSTRUCTION(6 downto 0) = "0110011" ) THEN
		TURN_MUX 	<= '0';
		IMM_TYPE 	<= "111";
		EX			<= "0010";
		MEM			<= "00";
		WB			<= "10";
		REG_READ1	<= INSTRUCTION(19 DOWNTO 15);
		REG_READ2	<= INSTRUCTION(24 DOWNTO 20);
		REG_DEST	<= INSTRUCTION(11 DOWNTO 7);
		DATA1		<= OPERAND1;
		DATA2		<= OPERAND2;

	-- JAL operation
	ELSIF ( INSTRUCTION(6 downto 0) = "1101111" ) THEN
		TURN_MUX 	<= '1';
		IMM_TYPE 	<= "100";
		EX			<= "0000";
		MEM			<= "00";
		WB			<= "10";
		REG_READ1	<= (others => '0');
		REG_READ2	<= (others => '0');
		REG_DEST	<= INSTRUCTION(11 DOWNTO 7);
		DATA1		<= PC;
		DATA2		<= std_logic_vector(to_signed(4, DATA2'length));

	-- SW operation
	ELSIF ( INSTRUCTION(14 downto 12) = "010"  AND INSTRUCTION(6 downto 0) = "0100011" ) THEN
		TURN_MUX 	<= '0';
		IMM_TYPE 	<= "001";
		EX			<= "1000";
		MEM			<= "10";
		WB			<= "00";
		REG_READ1	<= INSTRUCTION(19 DOWNTO 15);
		REG_READ2	<= INSTRUCTION(24 DOWNTO 20);
		REG_DEST	<= (others => '0');
		DATA1		<= OPERAND1;
		DATA2		<= OPERAND2;

	-- ABS operation
	ELSIF ( INSTRUCTION(31 downto 25) = "0000010" AND INSTRUCTION(14 downto 12) = "000"  AND INSTRUCTION(6 downto 0) = "0110011" ) THEN
		TURN_MUX 	<= '0';
		IMM_TYPE 	<= "111";
		EX			<= "0101";
		MEM			<= "00";
		WB			<= "10";
		REG_READ1	<= INSTRUCTION(19 DOWNTO 15);
		REG_READ2	<= (others => '0');
		REG_DEST	<= INSTRUCTION(11 DOWNTO 7);
		DATA1		<= OPERAND1;
		DATA2		<= OPERAND2;

	--invalid operation => equivalent to a bubble
	ELSE
		TURN_MUX 	<= '0';
		IMM_TYPE 	<= "111";
		EX			<= "0000";
		MEM			<= "00";
		WB			<= "00";
		REG_READ1	<= (others => '0');
		REG_READ2	<= (others => '0');
		REG_DEST	<= (others => '0');
		DATA1		<= (others => '0');
		DATA2		<= (others => '0');
	END IF;

END PROCESS;

END behaviour;

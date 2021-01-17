
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY ControlWord_Entity IS
GENERIC (
n : integer := 26
);
	PORT(
		uPC : INOUT std_logic_vector(8 DOWNTO 0);
		ControlWord : IN std_logic_vector(n-1 DOWNTO 0);
		clk : IN std_logic;
		HLT : INOUT std_logic;
		RST : INOUT std_logic);
END ENTITY ControlWord_Entity;

ARCHITECTURE ControlWordDecoder OF ControlWord_Entity IS

component ram_Entity IS
GENERIC (
n : integer := 16
);
	PORT(
		rst:IN std_logic;
		clk : IN std_logic;
		MAR : INOUT  std_logic_vector(10 DOWNTO 0);
		MDR : INOUT  std_logic_vector(n-1 DOWNTO 0);
		ReadWriteSignals:IN std_logic_vector(1 DOWNTO 0));
END component;

component PLA IS
	PORT (
	operationType: IN std_logic_vector(3 DOWNTO 0);
	IR: IN std_logic_vector(15 DOWNTO 0);
	F9: IN std_logic_vector(2 DOWNTO 0);
	branchCheck: IN std_logic;
	plaOut: OUT std_logic_vector(8 DOWNTO 0)
        );
END component;

COMPONENT branchFlag IS
	PORT (
	isBranch: IN std_logic;
	branchCode: IN std_logic_vector(2 DOWNTO 0);
	flags: IN std_logic_vector(1 DOWNTO 0);
	FlagOut:OUT std_logic
        );
END COMPONENT;

COMPONENT OperationSignals IS
  PORT (IR : IN std_logic_vector (15 downto 0);
  CodeWord : IN std_logic_vector (25 downto 0);
  OperationType : OUT std_logic_vector (3 downto 0);
  ALUSelector: OUT std_logic_vector (4 downto 0));
END COMPONENT;


COMPONENT alu IS
Generic ( n : Integer:=16);
  PORT (A,B : IN std_logic_vector (n-1 downto 0);
  selector : IN std_logic_vector (4 downto 0);
	cin: IN std_logic;
	F: OUT std_logic_vector (n-1 downto 0);
	cout : OUT std_logic);
END COMPONENT;

	-- Registers Signals -- 

	Signal MDR : std_logic_vector(15 DOWNTO 0);
	Signal MAR : std_logic_vector(15 DOWNTO 0);
	Signal Rsrc : std_logic_vector(15 DOWNTO 0);
	Signal Rdst : std_logic_vector(15 DOWNTO 0);
	Signal PC : std_logic_vector(15 DOWNTO 0);
	Signal IR : std_logic_vector(15 DOWNTO 0);
	Signal X : std_logic_vector(15 DOWNTO 0);
	Signal Y : std_logic_vector(15 DOWNTO 0);
	Signal Z : std_logic_vector(15 DOWNTO 0);
	Signal DataBus : std_logic_vector(15 DOWNTO 0);
	SIGNAL ENABLEIN:std_logic_vector(14 DOWNTO 0);		
	SIGNAL ENABLEOUT:std_logic_vector(14 DOWNTO 0);
	SIGNAL RAMCLK:std_logic:=not clk;
	Signal FlagRegister : std_logic_vector(2 DOWNTO 0);
	Signal OperationType : std_logic_vector(3 DOWNTO 0);
	Signal ALUselector : std_logic_vector(4 DOWNTO 0);
	Signal FlagOut:std_logic;
	-- Processor Data Bus --
	


	BEGIN
	-- Registers Decoders SHOULD BE CALLED HERE For In\OUT And Out the results to the Registers Signals , Should be Called For All Registers AND OUT TO THE DATABUS --
	
	
	-- Operation Type Handler	
	OperationSignalsComponent: OperationSignals port map (IR,ControlWord,OperationType,ALUselector);

	-- Branch Flag Test Handler
	branchFlagComponent: branchFlag port map (OperationType(0),IR(11 DOWNTO 9),FlagRegister(1 DOWNTO 0),FlagOut);

	
	-- ALU SHOULD TAKE LAST 3 BITS FROM uPC TO CHECK IF CHANGE FLAG REG CARRY OR NOT --
	--ALUComponent : alu GENERIC MAP (16) port map (X,Y,ControlWord(15 downto 11),FlagRegister(0),Z,FlagRegister(0));

	

	--NEEDS MODIFICATION
	PLAComponent:PLA port map (OperationType,IR,ControlWord(3 downto 1),FlagOut,uPC);

	-- RAM SHOULD BE CALLED HERE AND TAKES CW (8 DOWNTO 7) FOR READWRITE , MAR(10 DOWNTO 0) ,MDR THEN OUT TO THE MAR,MDR  --
	RAMComponent : ram_Entity GENERIC MAP (16) port map (RST,RAMCLK,MAR(10 DOWNTO 0),MDR,ControlWord(8 downto 7));
END ControlWordDecoder;
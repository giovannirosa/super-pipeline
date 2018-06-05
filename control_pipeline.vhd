library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MI0.all;

entity control_pipeline is
	port 	(
			opcode: in std_logic_vector(5 downto 0);
		 	RegDst: out std_logic; 
			ALUSrc: out std_logic; 
			RegWrite: out std_logic; 
			MemRead: out std_logic; 
			MemWrite: out std_logic; 
			Branch: out std_logic; 
			ALUOp: out std_logic_vector(1 downto 0)
		);
end control_pipeline;


architecture arq_control_pipeline of control_pipeline is


begin
   
    process (opcode)
    begin
        case opcode is
			  when R_FORMAT => RegDst <= '1'; ALUSrc <= '0'; RegWrite <='1'; MemRead<='0'; MemWrite<='0'; Branch<='0'; ALUOp <= "10"; -- R type
			  when LW => RegDst <= '0'; ALUSrc <= '1'; RegWrite <='1'; MemRead<='1'; MemWrite<='0'; Branch<='0'; ALUOp <= "00"; -- LW
			  when SW => RegDst <= 'X'; ALUSrc <= '1';  RegWrite <='0'; MemRead<='0'; MemWrite<='1'; Branch<='0'; ALUOp <= "00"; -- SW
			  when BEQ => RegDst <= 'X'; ALUSrc <= '0'; RegWrite <='0'; MemRead<='0'; MemWrite<='0'; Branch<='1'; ALUOp <= "01"; -- BEQ
			  when ADDI => RegDst <= '0'; ALUSrc <= '1'; RegWrite <='1'; MemRead<='0'; MemWrite<='0'; Branch<='0'; ALUOp <= "00"; -- ADDI
			  when others => RegDst <= '0'; ALUSrc <= '0'; RegWrite <='0'; MemRead<='0'; MemWrite<='0'; Branch<='0'; ALUOp <= "00";
		  end case;
	  end process;

  end arq_control_pipeline;

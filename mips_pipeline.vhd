library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_bit.all;
use work.p_MI0.all;

entity mips_pipeline is
	port (
			  clk: in std_logic;
			  reset: in std_logic
		  );
end mips_pipeline;


architecture arq_mips_pipeline of mips_pipeline is


	 -- ********************************************************************
	 --                              Signal Declarations
	 -- ********************************************************************

	 -- IF Signal Declarations

	signal IF_instr,IF_instr_prox, IF_pc, IF_pc_next, IF_pc_prox,IF_pc8 : reg32 := (others => '0');

	 -- ID Signal Declarations

	signal ID_instr,ID_instr_prox, ID_pc_prox ,ID_pc8:reg32;  -- pipeline register values from EX
	signal ID_op, ID_funct,ID_op_prox, ID_funct_prox: std_logic_vector(5 downto 0);
	signal id_rs, id_rt, id_rd, id_rs_prox, id_rt_prox, id_rd_prox: std_logic_vector(4 downto 0);
	signal ID_immed,ID_immed_prox: std_logic_vector(15 downto 0);
	signal ID_extend, ID_A, ID_B,ID_extend_prox, ID_A_prox, ID_B_prox,ID_btgt,ID_ALUOut,ID_offset: reg32;
	signal ID_RegWrite, ID_Branch, ID_RegDst, ID_MemtoReg, ID_MemRead, ID_MemWrite, ID_ALUSrc: std_logic; --ID Control Signals	
	signal ID_RegWrite_prox, ID_Branch_prox, ID_RegDst_prox, ID_MemtoReg_prox, ID_MemRead_prox, ID_MemWrite_prox, ID_ALUSrc_prox: std_logic; --ID_prox Control Signals
	signal ID_ALUOp,ID_ALUOp_prox: std_logic_vector(1 downto 0);
	signal ID_Zero: std_logic;
	signal ID_Operation: std_logic_vector(2 downto 0);
	 -- EX Signals

	signal EX_pc8, EX_extend, EX_A, EX_B,EX_extend_prox, EX_A_prox, EX_B_prox: reg32;
	signal EX_offset,EX_offset_prox, EX_alub, EX_ALUOut,EX_alub_prox, EX_ALUOut_prox: reg32;
	signal EX_rt, EX_rd,EX_rt_prox, EX_rd_prox: std_logic_vector(4 downto 0);
	signal EX_RegRd,EX_RegRd_prox: std_logic_vector(4 downto 0);
	signal EX_funct,EX_funct_prox: std_logic_vector(5 downto 0);
	signal EX_RegWrite, EX_Branch, EX_RegDst, EX_MemtoReg, EX_ALUSrc: std_logic;  -- EX Control Signals
	signal EX_RegWrite_prox ,EX_RegDst_prox, EX_MemRead_prox, EX_MemWrite_prox, EX_ALUSrc_prox: std_logic;  -- EX_prox Control Signals
	signal EX_Zero,EX_Zero_prox: std_logic;
	signal EX_ALUOp,EX_ALUOp_prox: std_logic_vector(1 downto 0);
	signal EX_Operation,EX_Operation_prox: std_logic_vector(2 downto 0);



	 -- MEM Signals

	signal MEM_PCSrc: std_logic;
	signal MEM_RegWrite, MEM_Branch, MEM_Zero: std_logic;
	signal MEM_RegWrite_prox, MEM_MemRead_prox, MEM_MemWrite_prox, MEM_Zero_prox: std_logic;
	signal MEM_ALUOut,MEM_ALUOut_prox, MEM_B,MEM_B_prox: reg32;
	signal MEM_memout_prox: reg32;
	signal MEM_RegRd,MEM_RegRd_prox: std_logic_vector(4 downto 0);


	 -- WB Signals

	signal WB_RegWrite,WB_RegWrite_prox: std_logic;  -- WB Control Signals
	signal WB_memout_prox, WB_ALUOut,WB_ALUOut_prox: reg32;
	signal WB_RegRd,WB_RegRd_prox: std_logic_vector(4 downto 0);



begin -- BEGIN MIPS_PIPELINE ARCHITECTURE

	 -- ********************************************************************
	 --                              IF Stage
	 -- ********************************************************************

	 -- IF Hardware

	PC: entity work.reg port map (clk, reset, IF_pc_next, IF_pc); 

	PC_prox: entity work.add32 port map (IF_pc, x"00000004", IF_pc_prox);

	PC8: entity work.add32 port map (IF_pc_prox, x"00000004", IF_pc8); -- Registrador que guarda a proxima instrução, após as duas lidas no momento.

	MX2: entity work.mux2 port map (MEM_PCSrc, IF_pc8, ID_btgt, IF_pc_next); --PC receberá Branch ou PC + 8

	ROM_INST: entity work.rom32 port map (IF_pc, IF_instr); --Decodifica R-Type ou Branch

	ROM_INST_prox: entity work.rom32 port map (IF_pc_prox, IF_instr_prox); --Decodifica LW ou SW

	IF_s: process(clk)
	begin     			-- IF/ID Pipeline Register
		if rising_edge(clk) then
			if reset = '1' then
				ID_instr <= (others => '0');
				ID_instr_prox<= (others => '0');
				ID_pc8  <= (others => '0');
			else
				ID_instr <= IF_instr;
				ID_instr_prox <= IF_instr_prox;
				ID_pc8  <=  ID_pc8;
			end if;
		end if;
	end process;



	 -- ********************************************************************
	 --                              ID Stage
	 -- ********************************************************************

	ID_op <= ID_instr(31 downto 26);
	ID_rs <= ID_instr(25 downto 21);
	ID_rt <= ID_instr(20 downto 16);
	ID_rd <= ID_instr(15 downto 11);
	ID_immed <= ID_instr(15 downto 0);

	ID_op_prox <= ID_instr_prox(31 downto 26);
	ID_rs_prox <= ID_instr_prox(25 downto 21);
	ID_rt_prox <= ID_instr_prox(20 downto 16);
	ID_rd_prox <= ID_instr_prox(15 downto 11);
	ID_immed_prox <= ID_instr_prox(15 downto 0);

	REG_FILE: entity work.reg_bank port map ( clk, reset, WB_RegWrite, WB_RegWrite_prox,ID_rs, ID_rt, WB_RegRd, ID_rs_prox, ID_rt_prox, WB_RegRd_prox,ID_A, ID_B,ID_A_prox, ID_B_prox,WB_ALUOut,
														 	WB_memout_prox);


	 -- sign-extender
	EXT: process(ID_immed)
	begin
		if ID_immed(15) = '1' then
			ID_extend <= x"FFFF" & ID_immed(15 downto 0);
		else
			ID_extend <= x"0000" & ID_immed(15 downto 0);
		end if;
	end process;

	 -- sign-extender2
	EXT_prox: process(ID_immed_prox)
	begin
		if ID_immed_prox(15) = '1' then
			ID_extend_prox <= x"FFFF" & ID_immed_prox(15 downto 0);
		else
			ID_extend_prox <= x"0000" & ID_immed_prox(15 downto 0);
		end if;
	end process;


	CTRL: entity work.control_pipeline port map (ID_op, ID_RegDst, ID_ALUSrc, ID_RegWrite, ID_MemRead, ID_MemWrite, ID_Branch, ID_ALUOp);

	CTRL_prox: entity work.control_pipeline port map (ID_op_prox, ID_RegDst_prox, ID_ALUSrc_prox, ID_RegWrite_prox, ID_MemRead_prox, ID_MemWrite_prox, ID_Branch_prox, ID_ALUOp_prox);
		--Branch estágio ID
	ID_funct <= ID_extend(5 downto 0);  

	ALU_h_ID: entity work.alu port map (ID_Operation, ID_A, ID_B, ID_ALUOut, ID_Zero);

	ALU_c_ID: entity work.alu_ctl port map (ID_ALUOp, ID_funct, ID_Operation);


	 -- branch offset shifter
	SIGN_EXT: entity work.shift_left port map (ID_extend, 2, ID_offset);

	BRANCH_ADD: entity work.add32 port map (ID_pc8, ID_offset, ID_btgt);

	MEM_PCSrc <= ID_Branch and ID_Zero;

	ID_EX_pip: process(clk)		    -- ID/EX Pipeline Register
	begin
		if rising_edge(clk) then
			if reset = '1' then
				EX_RegDst   <= '0';
				EX_ALUOp    <= (others => '0');
				EX_ALUSrc   <= '0';
				EX_Branch   <= '0';
				EX_RegWrite <= '0';

				EX_RegDst_prox   <= '0';
				EX_ALUSrc_prox   <= '0';
				EX_MemRead_prox  <= '0';
				EX_MemWrite_prox <= '0';
				EX_RegWrite_prox <= '0';

				EX_pc8      <= (others => '0');
				EX_A        <= (others => '0');
				EX_B        <= (others => '0');
				EX_extend   <= (others => '0');
				EX_rt       <= (others => '0');
				EX_rd       <= (others => '0');

				EX_ALUOp_prox   <= (others => '0');				
				EX_A_prox        <= (others => '0');
				EX_B_prox       <= (others => '0');
				EX_extend_prox   <= (others => '0');
				EX_rt_prox       <= (others => '0');
				EX_rd_prox       <= (others => '0');

			else 
				EX_RegDst   <= ID_RegDst;
				EX_ALUOp    <= ID_ALUOp;
				EX_ALUSrc   <= ID_ALUSrc;
				EX_Branch   <= ID_Branch;
				EX_RegWrite <= ID_RegWrite;
			
				EX_RegDst_prox   <= ID_RegDst_prox;
				EX_ALUOp_prox    <= ID_ALUOp_prox;
				EX_ALUSrc_prox   <= ID_ALUSrc_prox;
				EX_MemRead_prox  <= ID_MemRead_prox;
				EX_MemWrite_prox <= ID_MemWrite_prox;
				EX_RegWrite_prox <= ID_RegWrite_prox;

				EX_pc8      <= ID_pc8;
				EX_A        <= ID_A;
				EX_B        <= ID_B;
				EX_extend   <= ID_extend;
				EX_rt       <= ID_rt;
				EX_rd       <= ID_rd;
	
				EX_A_prox        <= ID_A_prox;
				EX_B_prox        <= ID_B_prox;
				EX_extend_prox   <= ID_extend_prox;
				EX_rt_prox       <= ID_rt_prox;
				EX_rd_prox       <= ID_rd_prox;
			end if;
		end if;
	end process;

	 -- ********************************************************************
	 --                              EX Stage
	 -- ********************************************************************



	EX_funct <= EX_extend(5 downto 0);  


	ALU_MUX_A: entity work.mux2 port map (EX_ALUSrc, EX_B, EX_extend, EX_alub);

	ALU_h: entity work.alu port map (EX_Operation, EX_A, EX_alub, EX_ALUOut, EX_Zero);

	DEST_MUX2: entity work.mux2 generic map (5) port map (EX_RegDst, EX_rt, EX_rd, EX_RegRd);

	ALU_c: entity work.alu_ctl port map (EX_ALUOp, EX_funct, EX_Operation);

	ALU_prox_MUX_A: entity work.mux2 port map (EX_ALUSrc_prox, EX_B_prox, EX_extend_prox, EX_alub_prox);

	ALU_prox_h: entity work.alu port map (EX_Operation_prox, EX_A_prox, EX_alub_prox, EX_ALUOut_prox, EX_Zero_prox);

	DEST_prox_MUX2: entity work.mux2 generic map (5) port map (EX_RegDst_prox, EX_rt_prox, EX_rd_prox, EX_RegRd_prox);

	ALU_prox_c: entity work.alu_ctl port map (EX_ALUOp_prox, EX_funct_prox, EX_Operation_prox);


	EX_MEM_pip: process (clk)		    -- EX/MEM Pipeline Register
	begin
		if rising_edge(clk) then
			if reset = '1' then

				MEM_Branch   <= '0';
				MEM_RegWrite <= '0';
				MEM_Zero     <= '0';

				MEM_MemRead_prox  <= '0';
				MEM_MemWrite_prox <= '0';
				MEM_RegWrite_prox <= '0';
				MEM_Zero_prox     <= '0';
			
				MEM_ALUOut   <= (others => '0');
				MEM_B        <= (others => '0');
				MEM_RegRd    <= (others => '0');

				MEM_ALUOut_prox   <= (others => '0');
				MEM_B_prox        <= (others => '0');
				MEM_RegRd_prox    <= (others => '0');

			else
				MEM_Branch   <= EX_Branch;
				MEM_RegWrite <= EX_RegWrite;
				MEM_Zero     <= EX_Zero;

				MEM_MemRead_prox  <= EX_MemRead_prox;
				MEM_MemWrite_prox <= EX_MemWrite_prox;
				MEM_RegWrite_prox <= EX_RegWrite_prox;
				MEM_Zero_prox     <= EX_Zero_prox;

				MEM_ALUOut   <= EX_ALUOut;
				MEM_B        <= EX_B;
				MEM_RegRd    <= EX_RegRd;
				
				MEM_ALUOut_prox   <= EX_ALUOut_prox;
				MEM_B_prox        <= EX_B_prox;
				MEM_RegRd_prox    <= EX_RegRd_prox;
			end if;
		end if;
	end process;

	 -- ********************************************************************
	 --                              MEM Stage
	 -- ********************************************************************

	MEM_ACCESS: entity work.mem32 port map (clk, MEM_MemRead_prox, MEM_MemWrite_prox, MEM_ALUOut_prox, MEM_B_prox, MEM_memout_prox);


	MEM_WB_pip: process (clk)		-- MEM/WB Pipeline Register
	begin
		if rising_edge(clk) then
			if reset = '1' then
				WB_RegWrite <= '0';
				WB_ALUOut   <= (others => '0');
				WB_RegRd    <= (others => '0');

				WB_RegWrite_prox <= '0';
				WB_ALUOut_prox   <= (others => '0');
				WB_memout_prox   <= (others => '0');
				WB_RegRd_prox    <= (others => '0');
			else
				WB_RegWrite <= MEM_RegWrite;
				WB_ALUOut   <= MEM_ALUOut;
				WB_RegRd    <= MEM_RegRd;

				WB_RegWrite_prox <= MEM_RegWrite_prox;
				WB_ALUOut_prox   <= MEM_ALUOut_prox;
				WB_memout_prox   <= MEM_memout_prox;
				WB_RegRd_prox    <= MEM_RegRd_prox;
			end if;
		end if;
	end process;       

	 -- ********************************************************************
	 --                              WB Stage
	 -- ********************************************************************


--REG_FILE: reg_bank port map (clk, reset, WB_RegWrite, ID_rs, ID_rt, WB_RegRd, ID_A, ID_B, WB_wd); Obs: Realizamos no estágio ID


end arq_mips_pipeline;


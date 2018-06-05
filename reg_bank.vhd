--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Banco de registradores - 31 registradores de uso geral - reg(0): cte 0
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.Std_Logic_1164.all;
use ieee.STD_LOGIC_UNSIGNED.all;   
use work.p_MI0.all;

entity reg_bank is
       port( ck, rst, wreg,wreg_prox :    in std_logic;
             AdRs, AdRt, adRD : in std_logic_vector( 4 downto 0);--Registradores de PC -> R-Type
							 AdRs_prox, AdRt_prox, adRD_prox : in std_logic_vector( 4 downto 0);--Registradores de PC -> SW/LW
             RA, RB: out reg32;
             RA_prox, RB_prox: out reg32;  
		 		 RW,RW2 : in reg32 --WB_aluout e WB_memout
           );
end reg_bank;

architecture reg_bank of reg_bank is
   type bank is array(0 to 31) of reg32;
   signal reg: bank;                            
   signal wen,wen2 : reg32;
   signal icl : std_logic;
begin            
icl <= '0' when ck = '1' else '1';
    g1: for i in 0 to 31 generate        

			wen(i) <= '1' when (i/=0 and adRD=i and wreg='1') else '0'; --sinal de escrita para instrução R
			wen2(i)<= '1'when	 (i/=0 and adRD_prox=i and wreg_prox='1')  else '0'; --sinal de escrita para instrução LW/SW



         
        rx: entity work.reg32b_ce
			port map(ck=>icl, rst=>rst, ce=>wen(i), ce2=>wen2(i), D=>RW, D2=>RW2, Q=>reg(i));  
                

    end generate g1;      

    RA <= reg(CONV_INTEGER(AdRs));    
    RB <= reg(CONV_INTEGER(AdRt));    
    RA_prox <= reg(CONV_INTEGER(AdRs_prox));    
    RB_prox <= reg(CONV_INTEGER(AdRt_prox));   
end reg_bank;

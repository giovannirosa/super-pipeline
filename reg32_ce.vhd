--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Registrador genérico sensível à borda de subida do clock
-- com possibilidade de inicialização de valor
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MI0.all;

entity reg32_ce is
	generic( 
		width : integer := 32
	);

	port(  	ck, rst, ce : in std_logic;
               	D : in  std_logic_vector(width-1 downto 0);
               	Q : out std_logic_vector(width-1 downto 0)
        );
end reg32_ce;

architecture arq_reg32_ce of reg32_ce is 
begin

  process(ck, rst)
  begin
       if rst = '1' then
              Q <= (others => '0');
       elsif ck'event and ck = '0' then
		if ce = '1' then
              		Q <= D; 
		end if;
       end if;
  end process;
        
end arq_reg32_ce;

library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MI0.all;

entity reg32b_ce is
	generic( 
		width : integer := 32
	);

	port(  	ck, rst, ce, ce2 : in std_logic;
               	D, D2 : in  std_logic_vector(width-1 downto 0);
               	Q : out std_logic_vector(width-1 downto 0)
        );
end reg32b_ce;

architecture arq_reg32b_ce of reg32b_ce is 
begin

  process(ck, rst)
  begin
       if rst = '1' then
              Q <= (others => '0');
       elsif ck'event and ck = '0' then
		if ce = '1' then --Sinal ativo para escrita registrador R-Type ou Branch
              		Q <= D; 
								end if;
		if ce2 = '1' then  -- Sinal ativo para escrita registrador LW/SW
				Q <= D2;
       end if;
		 end if;
  end process;
        
end arq_reg32b_ce;

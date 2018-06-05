library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.p_MI0.all;



entity rom32 is
	port (
		address: in reg32;
		data_out: out reg32
	);
end rom32;

architecture arq_rom32 of rom32 is

	signal mem_offset: std_logic_vector(5 downto 0);
	signal address_select: std_logic;
	

begin
	mem_offset <= address(7 downto 2);
        
	add_sel: process(address)
	begin
		if address(31 downto 8) = x"000000" then 	
			address_select <= '1';
		else
			address_select <= '0';
		end if;
	end process;

	access_rom: process(address_select, mem_offset)
	begin
		if address_select = '1' then
			case mem_offset is
				when 	"000000" => data_out <= "101011" & "00001" & "00011" & x"0001"; -- sw $3, 1($1)
				when 	"000001" => data_out <= "000100" & "00000" & "00010" & x"0000"; -- beq $0, $2, 0
		--		when 	"000010" => data_out <= "000000" & "00000" & "00000" & "00000" & "00000" & "100000"; -- nop
		--		when 	"000011" => data_out <= "000000" & "00000" & "00000" & "00000" & "00000" & "100000"; -- nop
		--		when 	"000100" => data_out <= "000000" & "00010" & "00000" & "00101" & "00000" & "100000"; -- add $5, $2, $0
		--		when 	"000101" => data_out <= "100101" & "00000" & "00010" & x"0000"; -- lw $2, 0($0)
		--		when 	"000110" => data_out <= "001000" & "00000" & "00101" & x"0001"; -- addi $5, $0, 1
		--		when 	"000111" => data_out <= "101011" & "00001" & "00011" & x"0001"; -- sw $3, 1($1)
		--		when 	"001000" => data_out <= "000000" & "00000" & "00000" & "00000" & "00000" & "100000"; -- nop
		--		when 	"001001" => data_out <= "000000" & "00000" & "00000" & "00000" & "00000" & "100000"; -- nop
		--		when 	"001010" => data_out <= "000000" & "00000" & "00000" & "00000" & "00000" & "100000"; -- nop
		--		when 	"001011" => data_out <= "000000" & "00000" & "00000" & "00000" & "00000" & "100000"; -- nop
		--		when 	"001100" => data_out <= "000000" & "00000" & "00000" & "00000" & "00000" & "100000"; -- nop
		--		when 	"001101" => data_out <= "000000" & "00000" & "00000" & "00000" & "00000" & "100000"; -- nop
		--		when 	"001110" => data_out <= "000000" & "00011" & "00101" & "00101" & "00000" & "100000"; -- add $5, $3, $5
		--		when 	"001111" => data_out <= "100101" & "00001" & "00010" & x"0001"; -- lw $2, 1($1)
		--		when 	"010000" => data_out <= "000000" & "00000" & "00000" & "00000" & "00000" & "100000"; -- nop
		--		when 	"010001" => data_out <= "000000" & "00000" & "00000" & "00000" & "00000" & "100000"; -- nop
		--		when 	"010010" => data_out <= "000000" & "00000" & "00000" & "00000" & "00000" & "100000"; -- nop
		--		when 	"010011" => data_out <= "000000" & "00000" & "00000" & "00000" & "00000" & "100000"; -- nop
		--		when 	"010100" => data_out <= "000000" & "00000" & "00000" & "00000" & "00000" & "100000"; -- nop
		--		when 	"010101" => data_out <= "000000" & "00000" & "00000" & "00000" & "00000" & "100000"; -- nop
		--		when 	"010110" => data_out <= "000000" & "00010" & "00101" & "00101" & "00000" & "100000"; -- add $5, $2, $5
				when 	others  => data_out <= (others => 'X');
			end case;
    		end if;
  	end process; 

end arq_rom32;

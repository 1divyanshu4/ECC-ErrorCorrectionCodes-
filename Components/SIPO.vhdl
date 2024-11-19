library IEEE;
use IEEE.std_logic_1164.all;
 
entity SIPO is
	generic( 
			n : integer := 7);
	port(
			CLK, RESET : in std_logic;
			A : in std_logic; -- Here, A is the data input that we will be serially inserting
			B : buffer std_logic_vector(n-1 downto 0) ); -- Here, B is the output that we will be getting as an vector
																 -- which is parallel
end SIPO;
 
architecture Behavioral of SIPO is
 
begin
 
	process (CLK)
	begin
		if RESET = '1' then
			B <= (others => '0');
		elsif (CLK'event and CLK='1') then
			B(n-1 downto 1) <= B(n-2 downto 0);
			B(0) <= A;
		end if;
	end process;
end  Behavioral;

library IEEE;
use IEEE.std_logic_1164.all;

entity OR_2 is
	port(I0, I1 : in std_logic;
		     O0 : out std_logic );
			  
end OR_2;
	
architecture FUNCTIONALITY of OR_2 is

begin
   O0 <= I0 OR I1;		
end FUNCTIONALITY;

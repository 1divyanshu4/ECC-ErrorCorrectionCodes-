library IEEE;
use IEEE.std_logic_1164.all;

entity AND_2 is
	port(I0, I1 : in std_logic;
		     O0 : out std_logic );
end AND_2;
	
architecture FUNCTIONALITY of AND_2 is
begin
   O0 <= I0 AND I1;
end FUNCTIONALITY;

library IEEE;
use ieee.std_logic_1164.all;
use work.ECC.all;

entity MUX_2X1 is
	port(I0, I1, S0 : in std_logic; -- Inputs
			O0 : out std_logic); -- Output
end MUX_2X1;

architecture STRUCTURE of MUX_2X1 IS

	signal S1,S2,S3 : std_logic;
begin 
	U0 : NOT_1 port map (S0,S1);
	U1 : AND_2 PORT MAP(I0,S1,S2);
	U2 : AND_2 PORT MAP(S0,I1,S3);
	U3 : OR_2 PORT MAP(S2,S3,O0);
	
END STRUCTURE;
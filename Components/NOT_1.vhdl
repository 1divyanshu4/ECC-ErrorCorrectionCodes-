library IEEE;
use IEEE.std_logic_1164.all;

entity NOT_1 is
    port(I0 : in std_logic;          
         O0 : out std_logic); 
end NOT_1;

architecture FUNCTIONALITY of NOT_1 is

begin
    O0 <= not(I0) ;
end FUNCTIONALITY;

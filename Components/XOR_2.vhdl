library ieee;
use ieee.std_logic_1164.all;
use work.ECC.all;

entity XOR_2 is
    port (I0,I1 :in std_logic;
          O0: out std_logic);
end XOR_2;

architecture Functionality of XOR_2 is

signal S0,S1,S2,S3:std_logic;

begin
  U0:NOT_1 port map (I0,S0);
  U1:NOT_1 port map (I1,S1);
  U2:AND_2 port map (I0,S1,S2);
  U3:AND_2 port map (S0,I1,S3);
  U4:OR_2 port map(S2,S3,O0);
end Functionality;

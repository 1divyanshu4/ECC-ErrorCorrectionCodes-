library ieee; -- Import the IEEE library
use ieee.std_logic_1164.all; -- Use standard logic functionality
use work.ECC.all; -- Import the ECC package from the current working library (if applicable)

-- Entity declaration for HCE4x7
entity HCE4x7 is
    port( 
        I : in std_logic_vector(3 downto 0);  -- 4-bit input vector
        O : out std_logic_vector(6 downto 0) -- 7-bit output vector
    );
end entity;

-- Architecture definition for the functionality of HCE4x7
architecture FUNCTIONALITY of HCE4x7 is
    -- signal S : std_logic_vector(1 downto 0); -- (Optional) Intermediate signals for modular design
begin

    -- Logic for generating output bits O(0) to O(3) based on input bits
    O(0) <= I(0) xor I(1) xor I(3); -- O(0) is the XOR of I(0), I(1), and I(3)
    O(1) <= I(0) xor I(2) xor I(3); -- O(1) is the XOR of I(0), I(2), and I(3)
    O(3) <= I(1) xor I(2) xor I(3); -- O(3) is the XOR of I(1), I(2), and I(3)

    -- The following commented-out code can be used for modular design:
    -- U0 : XOR_2 port map(I(0), I(1), S(0)); -- S(0) is the XOR of I(0) and I(1)
    -- U1 : XOR_2 port map(S(0), I(3), O(0)); -- O(0) is the XOR of S(0) and I(3)
    -- U2 : XOR_2 port map(I(2), I(3), S(1)); -- S(1) is the XOR of I(2) and I(3)
    -- U3 : XOR_2 port map(S(1), I(0), O(1)); -- O(1) is the XOR of S(1) and I(0)
    -- U4 : XOR_2 port map(S(1), I(1), O(3)); -- O(3) is the XOR of S(1) and I(1)

    -- Direct mapping of input bits I(0) to I(3) to corresponding output bits O(2) to O(6)
    O(2) <= I(0); -- O(2) is directly mapped to I(0)
    O(4) <= I(1); -- O(4) is directly mapped to I(1)
    O(5) <= I(2); -- O(5) is directly mapped to I(2)
    O(6) <= I(3); -- O(6) is directly mapped to I(3)

end FUNCTIONALITY;

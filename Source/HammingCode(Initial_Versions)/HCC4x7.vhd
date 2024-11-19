library ieee; -- Import the IEEE library
use ieee.std_logic_1164.all; -- Use standard logic functionality
use work.ECC.all; -- Import the ECC package from the current working library (if applicable)

-- Entity declaration for Hamming Code Corrector
entity HCC4x7 is 
    port( 
        I : in std_logic_vector(3 downto 0);  -- 4-bit input vector
        O : buffer std_logic_vector(6 downto 0); -- 7-bit encoded and corrected output vector
        B : out std_logic_vector(3 downto 0)    -- Decoded output vector
    );
end entity;

-- Architecture definition for the Hamming Code Corrector
architecture structure of HCC4x7 is
    -- Signal declarations
    signal S : std_logic_vector(6 downto 0);  -- Encoded signal
    signal S1 : std_logic_vector(6 downto 0); -- Complement of encoded signal
    signal X : std_logic_vector(5 downto 0);  -- Intermediate XOR signals
    signal C : std_logic_vector(2 downto 0);  -- Syndrome bits
    signal C1 : std_logic_vector(2 downto 0); -- Complement of syndrome bits
    signal Y : std_logic_vector(6 downto 0);  -- Correction vector
    signal M : std_logic_vector(3 downto 0);  -- Control signals for correction
begin 

    -- Encode the input data using Hamming code
    U0 : HCE4x7 port map(I, S);

    -- Syndrome calculation for error detection
    U1 : XOR_2 PORT MAP (S(4), S(6), X(0));
    U2 : XOR_2 PORT MAP (S(0), S(2), X(1));
    U3 : XOR_2 PORT MAP (X(0), X(1), C(0)); -- First syndrome bit

    U4 : XOR_2 PORT MAP (S(2), S(5), X(2));
    U5 : XOR_2 PORT MAP (S(6), S(1), X(3));
    U6 : XOR_2 PORT MAP (X(2), X(3), C(1)); -- Second syndrome bit

    U7 : XOR_2 PORT MAP (S(6), S(3), X(4));
    U55 : XOR_2 PORT MAP (S(4), S(5), X(5));
    U8 : XOR_2 PORT MAP (X(5), X(4), C(2)); -- Third syndrome bit

    -- Generate complement of syndrome bits
    U9 : NOT_1 PORT MAP (C(2), C1(2));
    U10 : NOT_1 PORT MAP (C(1), C1(1));
    U11 : NOT_1 PORT MAP (C(0), C1(0));

    -- Generate correction vector Y
    U12 : AND_2 PORT MAP (C1(2), C1(1), M(0));
    U13 : AND_2 PORT MAP (M(0), C(0), Y(0)); -- Correct bit 0

    U14 : AND_2 PORT MAP (C1(2), C(1), M(1));
    U15 : AND_2 PORT MAP (M(1), C1(0), Y(1)); -- Correct bit 1

    U16 : AND_2 PORT MAP (M(1), C(0), Y(2)); -- Correct bit 2

    U17 : AND_2 PORT MAP (C(2), C1(1), M(2));
    U18 : AND_2 PORT MAP (M(2), C1(0), Y(3)); -- Correct bit 3

    U19 : AND_2 PORT MAP (M(2), C(0), Y(4)); -- Correct bit 4

    U20 : AND_2 PORT MAP (C(2), C(1), M(3));
    U21 : AND_2 PORT MAP (M(3), C1(0), Y(5)); -- Correct bit 5

    U22 : AND_2 PORT MAP (M(3), C(0), Y(6)); -- Correct bit 6

    -- Generate complement of encoded bits for correction
    U23 : NOT_1 PORT MAP (S(0), S1(0));
    U24 : NOT_1 PORT MAP (S(1), S1(1));
    U25 : NOT_1 PORT MAP (S(2), S1(2));
    U26 : NOT_1 PORT MAP (S(3), S1(3));
    U27 : NOT_1 PORT MAP (S(4), S1(4));
    U28 : NOT_1 PORT MAP (S(5), S1(5));
    U29 : NOT_1 PORT MAP (S(6), S1(6));

    -- Apply correction using multiplexers
    U30 : MUX_2X1 PORT MAP (S(0), S1(0), Y(0), O(0));
    U31 : MUX_2X1 PORT MAP (S(1), S1(1), Y(1), O(1));
    U32 : MUX_2X1 PORT MAP (S(2), S1(2), Y(2), O(2));
    U33 : MUX_2X1 PORT MAP (S(3), S1(3), Y(3), O(3));
    U34 : MUX_2X1 PORT MAP (S(4), S1(4), Y(4), O(4));
    U35 : MUX_2X1 PORT MAP (S(5), S1(5), Y(5), O(5));
    U36 : MUX_2X1 PORT MAP (S(6), S1(6), Y(6), O(6));

    -- Extract original data from corrected code
    B(0) <= O(2); -- Extract bit 0
    B(1) <= O(4); -- Extract bit 1
    B(2) <= O(5); -- Extract bit 2
    B(3) <= O(6); -- Extract bit 3

end structure;

library IEEE; -- Import the IEEE library
use IEEE.std_logic_1164.all; -- Use standard logic functionality
use IEEE.numeric_std.all; -- Use numeric operations for unsigned and signed types

-- Entity declaration for Exxtended Hamming Code Encoder
entity Generic_extended_HCE_matrix is
    generic( 
        n : integer := 4; -- Number of data bits
        k : integer := 3  -- Number of parity bits (excluding the extra parity bit)
    );
    port (
        A : in  std_logic_vector (n-1 downto 0); -- Input data vector
        B : out std_logic_vector (n+k downto 0)  -- Encoded output vector
    );
end entity;

-- Architecture definition for Generic_extended_HCE_matrix
architecture Behavioral of Generic_extended_HCE_matrix is 

    -- Type declarations for multi-dimensional arrays
    type TwoDimensionalArray is array (natural range <>) of std_logic_vector(k-1 downto 0);
    type TwoDimensionalArray1 is array (natural range <>) of std_logic_vector(n-1 downto 0);

    -- Signal declarations
    signal C : TwoDimensionalArray(0 to n-1); -- Parity matrix
    signal B1 : std_logic_vector(k-1 downto 0); -- Parity bits

    -- Function to perform matrix multiplication
    function MAT_MUL(
        p : integer := 1; -- Rows in matrix A
        q : integer := 3; -- Columns in matrix A / Rows in matrix B
        r : integer := 8; -- Columns in matrix B
        A : TwoDimensionalArray1; -- Input matrix A
        B : TwoDimensionalArray -- Input matrix B
    ) return std_logic_vector is
        type TwoDimensionalArray2 is array (natural range <>) of std_logic_vector(r-1 downto 0);
        variable temp : TwoDimensionalArray2(0 to p-1);
        variable sum : TwoDimensionalArray2(0 to p-1);
        variable C1 : TwoDimensionalArray2(0 to p-1);
        variable C : std_logic_vector(p*r-1 downto 0);
    begin
        -- Perform matrix multiplication
        for i in 0 to p-1 loop
            for j in 0 to r-1 loop
                temp := (others => (others => '0')); -- Reset temporary values
                for k in 0 to q-1 loop
                    temp(i)(j) := temp(i)(j) XOR (A(i)(k) AND B(k)(j)); -- XOR-based multiplication
                end loop;
                sum(i)(j) := temp(i)(j); -- Update sum with XOR results
            end loop;
        end loop;

        C1 := sum; -- Store result matrix

        -- Flatten the 2D matrix into a 1D vector
        for i in 0 to p-1 loop
            for j in 0 to r-1 loop
                C((i * r) + j) := C1(i)(j);
            end loop;
        end loop;

        return C; -- Return the 1D result vector
    end function MAT_MUL;

begin

    -- Generate the parity matrix dynamically
    process (A) 
        variable x : integer := 0; -- Counter for power of 2
    begin
        for i in 1 to n+k loop
            if (i = 2**x) then
                x := x + 1; -- Skip positions that are powers of 2
            else
                C((i-1)-x) <= std_logic_vector(to_unsigned(i, k)); -- Populate parity matrix
            end if;
        end loop;
    end process;

    -- Generate parity bits by multiplying the data vector with the parity matrix
    process(A, C)
        variable A1 : TwoDimensionalArray1(0 to 0); -- Convert data vector to 2D matrix
    begin
        -- Populate A1 from input vector A
        for j in 0 to n-1 loop
            A1(0)(j) := A(j);
        end loop;

        -- Perform matrix multiplication to calculate parity bits
        B1 <= MAT_MUL(p => 1, q => n, r => k, A => A1, B => C);
    end process;

    -- Generate the final output vector with parity and data bits
    process(A, B1)
        variable m : integer := 0; -- Counter for parity bit positions
        variable z : integer := 0; -- Counter for data bit positions
        variable B2 : std_logic_vector(n+k downto 0); -- Temporary output vector
    begin
        B2 := (others => '0'); -- Initialize output vector

        -- Place parity and data bits at appropriate positions
        for i in 0 to n+k-1 loop
            if (i = 2**m - 1) then
                B2(i) := B1(i - z); -- Insert parity bits at power-of-2 positions
                m := m + 1;
            else
                B2(i) := A(i - m); -- Insert data bits at other positions
                z := z + 1;
            end if;
        end loop;

        -- Calculate the overall parity bit for even parity
        for j in 0 to n+k-1 loop
            B2(n+k) := B2(n+k) XOR B2(j); -- XOR all bits for even parity
        end loop;

        B <= B2; -- Assign the output vector
    end process;

end architecture;

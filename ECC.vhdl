library ieee; -- Import IEEE library
use ieee.std_logic_1164.all; -- Use standard logic functionalities

-- Package declaration for ECC (Error Correcting Codes)
package ECC is

	-- Component declaration for a NOT gate
	component NOT_1 is
        port(
            I0 : in std_logic;          -- Input signal
            O0 : out std_logic          -- Output signal (inverted)
        ); 
	end component;
	
	-- Component declaration for a 2-input XOR gate
	component XOR_2 is
        port(
            I0, I1 : in std_logic;      -- Input signals
            O0 : out std_logic          -- Output signal (XOR of inputs)
        );
	end component;

	-- Component declaration for a 2-input AND gate
	component AND_2 is
        port(
            I0, I1 : in std_logic;      -- Input signals
            O0 : out std_logic          -- Output signal (AND of inputs)
        );
	end component;

	-- Component declaration for a 2-input OR gate
	component OR_2 is
        port(
            I0, I1 : in std_logic;      -- Input signals
            O0 : out std_logic          -- Output signal (OR of inputs)
        );
	end component;

	-- Component declaration for a 2-to-1 multiplexer
	component MUX_2X1 is
        port(
            I0, I1, S0 : in std_logic;  -- Inputs (two data inputs and one select signal)
            O0 : out std_logic          -- Output (selected input based on S0)
        );
	end component;
	
	-- Component declaration for a Hamming Code Encoder (4 data bits to 7 encoded bits)
	component HCE4x7 is
        port(
            I : in std_logic_vector(3 downto 0); -- Input vector (4 data bits)
            O : out std_logic_vector(6 downto 0) -- Output vector (7 encoded bits)
        );
	end component;
	
	-- Component declaration for a Serial-In Parallel-Out (SIPO) shift register
	component SIPO is
        generic( 
            n : integer := 7 -- Length of the parallel output vector
        );
        port(
            CLK, RESET : in std_logic;         -- Clock and reset signals
            A : in std_logic;                  -- Serial data input
            B : buffer std_logic_vector(n-1 downto 0) -- Parallel data output
        );
	end component;

	-- Component declaration for matrix addition
	component MAT_ADD is
        generic( 
            m : integer := 4; -- Number of rows in the matrices
            n : integer := 4  -- Number of columns in the matrices
        );
        port(
            A : in std_logic_vector(m*n-1 downto 0); -- Input matrix A (flattened 1D vector)
            B : in std_logic_vector(m*n-1 downto 0); -- Input matrix B (flattened 1D vector)
            C : out std_logic_vector(m*n-1 downto 0); -- Output matrix C (result of addition)
            Carry : out std_logic                 -- Carry output for cases of overflow
        );
	end component;

	-- Component declaration for matrix multiplication
	component MAT_MUL is
        generic( 
            m : integer := 1; -- Number of rows in matrix A
            n : integer := 4; -- Number of columns in matrix A / rows in matrix B
            k : integer := 7  -- Number of columns in matrix B
        );
        port(
            A : in std_logic_vector(m*n-1 downto 0); -- Input matrix A (flattened 1D vector)
            B : in std_logic_vector(n*k-1 downto 0); -- Input matrix B (flattened 1D vector)
            C : out std_logic_vector(m*k-1 downto 0) -- Output matrix C (result of multiplication)
        );
	end component;
	
end ECC;

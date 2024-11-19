library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Generic Hamming Code Corrector by Matrix Method with one-bit Error Detection and Correction Capability

-- Entity Definition

entity Generic_HCC_matrix is
	generic( 
		n : integer := 4;  -- Length of the original message
		k : integer := 3   -- Number of parity bits
	);
	port (
		A : in  std_logic_vector (n+k-1 downto 0); -- Input vector (message + parity bits)
		B : out std_logic_vector (n-1 downto 0);   -- Corrected output vector (original message)
		error : out std_logic                     -- Error signal: '1' if an error is detected, '0' otherwise
	);
end entity;

-- Architecture of Hamming Code Corrector
architecture Behavioral of Generic_HCC_matrix is 

	-- Define custom types for two-dimensional arrays used for matrix operations
	type TwoDimensionalArray is array (natural range <>) of std_logic_vector(0 downto 0);
	type TwoDimensionalArray1 is array (natural range <>) of std_logic_vector(n+k-1 downto 0);

	-- Signal declarations
	signal H : TwoDimensionalArray1(0 to k-1); -- Check matrix (H)
	signal S : std_logic_vector(k-1 downto 0); -- Syndrome vector (S)
	signal B1 : std_logic_vector (n+k-1 downto 0); -- Corrected input vector (A after error correction)

	-- Function to perform matrix multiplication between A (kx(n+k)) and B ((n+k)x1)
	-- Result is a std_logic_vector of length p*r (in this case, k*1)
	function MAT_MUL(	
			p : integer := 1; -- Number of rows in matrix A
			q : integer := 3; -- Number of columns in matrix A and rows in matrix B
			r : integer := 8; -- Number of columns in matrix B
			A : TwoDimensionalArray1; -- Matrix A (H)
			B : TwoDimensionalArray  -- Matrix B (message vector)
		) return std_logic_vector is
	
		-- Internal variable declarations for matrix manipulation
		type TwoDimensionalArray2 is array (natural range <>) of std_logic_vector(r-1 downto 0);
		variable temp : TwoDimensionalArray2(0 to p-1);
		variable sum : TwoDimensionalArray2(0 to p-1);
		variable C1 : TwoDimensionalArray2(0 to p-1);
		variable C : std_logic_vector(p*r-1 downto 0); -- Result vector
	
	begin
		-- Perform matrix multiplication
		for i in 0 to p-1 loop
			for j in 0 to r-1 loop
				temp := (others => (others => '0')); -- Initialize temp to all '0's
				
				-- Perform XOR-based multiplication for Hamming check
				for k in 0 to q-1 loop
					temp(i)(j) := temp(i)(j) XOR (A(i)(k) AND B(k)(j));
				end loop;
	
				sum(i)(j) := temp(i)(j);
			end loop;
		end loop;
		
		C1 := sum;
		
		-- Convert the 2D matrix result (C1) into a 1D vector (C)
		for i in 0 to p-1 loop
			for j in 0 to r-1 loop
				C((i * r) + j) := C1(i)(j);
			end loop;
		end loop;
		
		return C;
		
	end function MAT_MUL;

begin

	-- Process to generate the check matrix H based on parity positions
	process(A)
	begin
		for i in 0 to k-1 loop
			for j in 0 to n+k-1 loop
				-- Determine if the current bit is a parity bit
				if ((j+1)/ 2**(k-1-i)) mod 2 = 1 then
					H(i)(n+k-1-j) <= '1';
				else 
					H(i)(n+k-1-j) <= '0';
				end if;
			end loop;
		end loop;
	end process;
	
	-- Process to calculate the syndrome vector (S) for error detection
	process(A, H)
		variable A1 : TwoDimensionalArray(0 to n+k-1); -- 2D version of input A
		variable S1 : std_logic_vector(k-1 downto 0);  -- Intermediate syndrome vector
	begin
		-- Convert the 1D input vector A into a 2D matrix (A1)
		for j in 0 to n+k-1 loop
			A1(j)(0) := A((n+k-1)-j);
		end loop;
		
		-- Generate the syndrome vector by multiplying the check matrix with the input
		S1 := MAT_MUL(p => k, q => n+k, r => 1, A => H, B => A1); 
		
		-- Reverse S1 to create the final syndrome vector S
		for j in 0 to k-1 loop
			S(j) <= S1((k - 1) - j);
		end loop;
	end process;
	
	-- Process for error detection and correction
	process(A, S, B1)
		variable err_pos : integer := 0; -- Position of detected error
	begin
		-- Determine the error position from the syndrome vector
		err_pos := to_integer(unsigned(S));
		
		-- Check if an error exists
		if (err_pos = 0) then
			error <= '0'; -- No error
		else 
			error <= '1'; -- Error detected
		end if;
		
		-- Correct the error if detected
		for i in 0 to n+k-1 loop
			if (i+1 = err_pos) then
				B1(i) <= NOT(A(i)); -- Correct the bit at the error position
			else 
				B1(i) <= A(i);       -- Copy the bit if no error
			end if;
		end loop;
	end process;
	
	-- Process to extract the original message from the corrected vector (B1)
	process(B1)
		variable x : integer;
		variable B2 : std_logic_vector(n-1 downto 0); -- Corrected message (original message)
	begin
		x := 0;
		B2 := (others => '0'); 
		
		-- Skip parity bits to extract the original message
		for i in 0 to n+k-1 loop
			if ( i = 2**x - 1 ) then
				x := x + 1; -- Skip parity bit positions
			else
				B2(i-x) := B1(i); -- Assign data bits to B2
			end if;
		end loop;
		
		B <= B2; -- Assign the corrected message to the output
	end process;
	
end architecture;

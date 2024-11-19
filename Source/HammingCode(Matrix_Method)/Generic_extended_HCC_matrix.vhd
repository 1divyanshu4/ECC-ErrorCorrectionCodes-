library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Generic Hamming Code Corrector by Matrix Method
-- Capable of detecting two-bit errors and correcting one-bit errors

-- Entity Definition
entity Generic_extended_HCC_matrix is
	generic(
		n : integer := 4; -- Number of data bits
		k : integer := 3  -- Number of parity bits
	);
	port (
		A : in  std_logic_vector (n+k downto 0); -- Input vector (data + parity bits + extra parity)
		B : out std_logic_vector (n-1 downto 0);  -- Corrected output vector (original message)
		error : out std_logic                     -- Error signal: '1' for two-bit error, '0' otherwise
	);
end entity;

-- Architecture Definition
architecture Behavioral of Generic_extended_HCC_matrix is

	-- Type Definitions for Matrix Operations
	type TwoDimensionalArray is array (natural range <>) of std_logic_vector(0 downto 0);
	type TwoDimensionalArray1 is array (natural range <>) of std_logic_vector(n+k downto 0);

	-- Signal Declarations
	signal H : TwoDimensionalArray1(0 to k);         -- Check matrix (H)
	signal S : std_logic_vector(k downto 0);          -- Syndrome vector (S)
	signal B1 : std_logic_vector(n+k downto 0);       -- Corrected input vector (A after error correction)

	-- Function for Matrix Multiplication
	-- Multiplies matrices A (pxq) and B (qxr) and returns a 1-dimensional result vector
	function MAT_MUL(	
			p : integer := 1; -- Number of rows in matrix A
			q : integer := 3; -- Number of columns in matrix A and rows in matrix B
			r : integer := 8; -- Number of columns in matrix B
			A : TwoDimensionalArray1; -- Matrix A (H)
			B : TwoDimensionalArray   -- Matrix B (message vector)
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
				
				-- Perform XOR-based multiplication for error detection
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
	
	-- Process to Generate the Check Matrix (H)
	process(A)
	begin
		for i in 0 to k loop
			for j in 0 to n+k loop
				if (i = k) then
					H(i)(j) <= '1'; -- Set the extra parity bit row to 1
				elsif ((j+1) / 2**(k-1-i)) mod 2 = 1 then
					H(i)(n+k-j) <= '1'; -- Set parity bit positions based on matrix configuration
				else 
					H(i)(n+k-j) <= '0'; -- Set other positions to 0
				end if;
			end loop;
		end loop;
	end process;
	
	-- Process to Calculate the Syndrome Vector (S) for Error Detection
	process(A, H)
		variable A1 : TwoDimensionalArray(0 to n+k); -- 2D version of input A
		variable S1 : std_logic_vector(k downto 0);  -- Intermediate syndrome vector
	begin
		-- Convert the 1D input vector A into a 2D matrix (A1)
		for j in 0 to n+k loop
			A1(j)(0) := A((n+k)-j);
		end loop;
		
		-- Generate the reversed syndrome vector (S1) by multiplying check matrix with input
		S1 := MAT_MUL(p => k+1, q => n+k+1, r => 1, A => H, B => A1);
		
		-- Reverse S1 to create the final syndrome vector S
		for j in 0 to k loop
			S(j) <= S1(k - j);
		end loop;
	end process;
	
	-- Process for Error Detection and Correction
	process(A, S, B1)
		variable error1 : integer := 0;
		variable error2 : std_logic;
		variable err_pos : integer := 0;
		variable S1 : std_logic_vector(k-1 downto 0);
	begin
		S1 := S(k downto 1);  -- Extract the primary error bits
		error1 := to_integer(unsigned(S1)); -- Convert to integer to find error position
		error2 := S(0); -- Extra parity bit error check
		
		-- Two-bit Error Detected
		if ((error2 = '0') AND (error1 /= 0)) then
			error <= '1'; -- Two-bit error, cannot correct
			
			-- Set corrected output to all zeros
			for i in 0 to n+k loop
				B1(i) <= '0';
			end loop;
		
		-- One-bit Error Detected (not in extra parity bit)
		elsif ((error2 = '1') AND (error1 /= 0)) then
			error <= '0'; -- One-bit error detected, can be corrected
			
			err_pos := error1; -- Determine the error position
			
			-- Correct the bit at the error position
			for i in 0 to n+k loop
				if (i+1 = err_pos) then
					B1(i) <= NOT(A(i));
				else 
					B1(i) <= A(i);
				end if;
			end loop;
		
		-- Error in Extra Parity Bit
		elsif ((error2 = '1') AND (error1 = 0)) then
			error <= '0'; -- Error in the extra parity bit, can be corrected
			
			-- Correct the extra parity bit
			B1(n+k) <= NOT(A(n+k));
			
			-- Copy the rest of the bits
			for i in 0 to n+k-1 loop 
				B1(i) <= A(i);
			end loop;
		
		-- No Error Detected
		else
			error <= '0'; -- No errors detected
			
			-- Copy the input to the corrected output
			for i in 0 to n+k loop 
				B1(i) <= A(i);
			end loop;
		end if;
	end process;
	
	-- Process to Extract the Original Message from Corrected Vector (B1)
	process(B1)
		variable x : integer;
		variable B2 : std_logic_vector(n-1 downto 0); -- Original message
	begin
		x := 0;
		B2 := (others => '0'); 
		
		-- Skip parity bits to extract the original message
		for i in 0 to n+k loop
			if ( i = 2**x - 1 ) then
				x := x + 1; -- Skip parity bit positions
			else
				B2(i-x) := B1(i); -- Assign data bits to B2
			end if;
		end loop;
		
		B <= B2; -- Assign the corrected message to the output
	end process;

end architecture;

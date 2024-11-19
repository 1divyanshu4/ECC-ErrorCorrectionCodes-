library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity HADAMARD_ENCODER is
	generic( 
			k : integer := 3; -- no. of data bits
			n : integer := 8);-- no. of bits in output, which is equal to 2**k, 
									-- indicating that it has n-k parity bits (( (2**k) - k ) parity bits)
   port (
		A : in  std_logic_vector (k-1 downto 0); -- Input vector of length k
      B : out std_logic_vector (n-1 downto 0)); -- Output vector of length n, of which k are data bits
																-- and n-k parity bits
end entity;

architecture Behavioral of HADAMARD_ENCODER is 

type TwoDimensionalArray is array (natural range <>) of std_logic_vector(n-1 downto 0); 
									-- Defining a matrix type which has n columns
type TwoDimensionalArray1 is array (natural range <>) of std_logic_vector(k-1 downto 0); --
									-- Defining a matrix type which has k columns

signal G : TwoDimensionalArray(0 to k-1); -- Defining a generator matrix G of size k x n

-- The function below performs the matrix multiplication operation, used to multiply matrices A and B of size pxq 
-- and qxr, in this case we have used it to multiply a A1 matrix of 1xk size and G matrix of kxn size which we 
-- used in getting a output vector B of n length

function MAT_MUL(	p : integer := 1;
						q : integer := 3;
						r : integer := 8;
						A : TwoDimensionalArray1;
						B : TwoDimensionalArray) return std_logic_vector is
	
	type TwoDimensionalArray2 is array (natural range <>) of std_logic_vector(r-1 downto 0);
	variable temp : TwoDimensionalArray2(0 to p-1);
	variable sum : TwoDimensionalArray2(0 to p-1);
	variable C1 : TwoDimensionalArray2(0 to p-1);
	variable C : std_logic_vector(p*r-1 downto 0);

begin
	
	for i in 0 to p-1 loop
		for j in 0 to r-1 loop
			temp := (others => (others => '0'));
		  
			for k in 0 to q-1 loop
				temp(i)(j) := temp(i)(j) XOR (A(i)(k) AND B(k)(j));
			end loop;

			sum(i)(j) := temp(i)(j);
		end loop;
   end loop;
		
	C1 := sum;
	
   -- Convert the 2-dimensional matrix C1 to 1-dimensional output array or vector C
		for i in 0 to p-1 loop
			for j in 0 to r-1 loop
				C((i * r) + j) := C1(i)(j);
			end loop;
		end loop;

	return C;
	
end function MAT_MUL;


begin

	-- This is a process to create a Generator matrix G, whose rows are such that in bottom row there are alternate 
	-- 0s 1s and second last row has alternate '00's and '11's and third last row has alternate '0000's and '1111's
	-- similarly the matrix is formed.
	process(A)
	begin
	
	for i in 0 to k-1 loop
		for j in 0 to n-1 loop
			if ((j)/ 2**(k-1-i)) mod 2 = 1 then
				G(i)((n-1)-j) <= '1';
			else 
				G(i)((n-1)-j) <= '0';
			end if;
		end loop;
	end loop;
	
	end process;
	
-- This is a proces in which G (created above) and MAT_MUL function is used to get a output vector B of n length
	
	process (A, G)
	variable A1 : TwoDimensionalArray1(0 to 0);
	begin
	
	-- Used for converting the 1-dimensional input array or vector A to 2-dimensional matrix A1 of 1xk size
		
	for j in 0 to k-1 loop
		A1(0)((k-1)-j) := A(j); 
	end loop;
	
	B <= MAT_MUL(p => 1, q => k, r => n, A => A1, B => G); 
	
	end process;
												
end architecture;
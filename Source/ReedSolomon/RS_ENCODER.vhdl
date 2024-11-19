library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RS_ENCODER is
	generic(
			k : integer := 3; -- No. of input symbols
			m : integer := 4; -- No. of bits of primitive polynomial
			n : integer := 7); -- Length of codeword
	port (
		I : in std_logic_vector (k*(m-1)-1 downto 0);  -- Input vector
		PP : in std_logic_vector (m-1 downto 0);  -- Primitive polynomial
		O : out std_logic_vector (n*(m-1)-1 downto 0));	-- Output vector
end entity;

architecture Behavioral of RS_ENCODER is 

-- The type INTEGERARRAY is used to define a 2-dimensioned matrix consisting of integers
type INTEGERARRAY is array (natural range <>, natural range <>) of integer;
signal IP : INTEGERARRAY(0 to 0, 0 to k-1);			-- A Matrix consisting of integers made from Input, of k length
signal OP : INTEGERARRAY(0 to 0, 0 to n-1);			-- A Matrix consisting of integers made from Output, of n length
signal GP : INTEGERARRAY(0 to 0, 0 to (n-k) );		-- Generator Polynomial, GP is of length (n-k)+1

-- The below function GAL_MUL is used to multiply two integers, a and b, each of whose bits representation will 
-- be of m-1 length, respectively. And the output would be part of GF(2**(m-1)), which depends on C.

function GAL_MUL( a : integer := 7;
						b : integer := 7;
						C : std_logic_vector(m-1 downto 0)) return integer is
	variable A1, A2, A3 : std_logic_vector(2*(m-2) downto 0); 
	variable B1 : std_logic_vector(m-2 downto 0);
	variable C1, C2, C3, D1 : std_logic_vector(2*(m-1)-2 downto 0);

begin

	-- Converting integer a into a vector A1, which is its binary representation of length 2*(m-1)-1 and an integer b 
	-- into a vector B1, which is its binary representation of length m-1
	A1(2*(m-2) downto 0) := std_logic_vector(to_unsigned(a,2*(m-1)-1));
	B1(m-2 downto 0) := std_logic_vector(to_unsigned(b,m-1));					
	
	-- Initializing vectors A2 and A3	
	A2 := (others => '0');				
	A3 := (others => '0');

	-- Here, i is running from 0 to m-2, and if B(i) = '1', then it is adding the vector A1 to A2 (which initially 
	-- is an all zero vector), and if B(i) = '0', then A2 remains same. And in every iteration of i, A1 is shifted 
	-- cyclic, in left direction.
	for i in 0 to m-2 loop
		if B1(i) = '1' then 		
			A2 := A2 XOR A1;		
		else 							
			A2 := A2;				
		end if;
		A3(2*(m-2) downto 1) := A1(2*(m-2)-1 downto 0);  				
		A3(0) := A1(2*(m-2));															
		A1 := A3;																					
	end loop;
	
	
	-- Initializing vector D1
	D1 := (others => '0'); 
	
	-- Converting C into a vector B1 such that the first m bits from left side are of C and rest all '0'
	D1(2*(m-1)-2 downto m-3) := C;
	C1 := A2;

	-- Here, there are m-2 iterations and in each iteration it checks whether the (2*(m-1)-i-2)th position is
	-- '1' or not,  if it is 1 then it adds D1 to C1 (which initially was an all zero vector), whereas if the 
	-- (2*(m-1)-i-2) th position is '0', then C1 remains as before, and B1 is getting shifted cycllicaly in 
	-- right direction
	for i in 0 to m-3 loop
	
		if ( C1(2*(m-1)-i-2) = '1' ) then   					
			C1 := C1 XOR D1;
		else
			C1 := C1;
		end if;
		
		C2(2*(m-1)-3 downto 0) := D1(2*(m-1)-2 downto 1);
		C2(2*(m-1)-2) := D1(0);
		D1 := C2;
		
	end loop;
	
	-- The function is returning vector C1 as an integer
	
	return to_integer(unsigned(C1));

end function GAL_MUL;

-- The function GP1, is used to create a generator polynomial of length n-k+1 on the basis of PP having 
-- primitive element as 2.

function GP1( 
				 PP : std_logic_vector(m-1 downto 0)) return INTEGERARRAY is 
				 
		variable b : integer := 1;
		variable a2 : integer := 1;
		variable D1 : std_logic_vector((m-1)-1 downto 0);
		variable D2 : std_logic_vector((m-1)-1 downto 0);
		variable A1 : INTEGERARRAY(0 to 0, 0 to n-k-1);
		variable B1 : INTEGERARRAY(0 to 0, 0 to n-k);
		variable B2 : INTEGERARRAY(0 to 0, 0 to 1);
		variable B3 : INTEGERARRAY(0 to 0, 0 to n-k+1);
		
begin
	
	b := 1;
	
	-- Here, a matrix A1 is created which is of q length, whose entries are A1(0, i) = p**(i+1)
	for i in 0 to n-k-1 loop

		A1(0, i) := GAL_MUL(a => b, b => 2, C => PP);
		b := A1(0, i);

	end loop;
	
	B1 := (others => (others => 0));
	B1(0, n-k-1) := 1;
	B1(0, n-k) := A1(0, 0);
	B2(0, 0) := 1;
	
	for i in 0 to (n-k-1)-1 loop
		
		B2(0, 1) := A1(0, i+1);
		B3 := (others => (others => 0));
		
		for j in 0 to 1 loop
			
			for l in 0 to n-k loop
				
				a2 := GAL_MUL(a => B2(0, 1-j), b => B1(0, l), C => PP);
				D1 := std_logic_vector(to_unsigned(B3(0, l-j+1), m-1));
				D2 := std_logic_vector(to_unsigneD(a2, m-1));
				D1 := D1 XOR D2;
				B3(0, l-j+1) := to_integer(unsigned(D1));
				
			end loop;
		
		end loop;
		
		for u in 0 to n-k loop
			B1(0, u) := B3(0, u+1);
		end loop;
		
	end loop;
	
	return B1;
	
end function GP1;

begin

	-- The below process is used to convert the input vector consisting of bits into an array, of 1xk size, where
	-- each element of the array is an integer of m-1 bits
	process(I)
	variable IP1 : INTEGERARRAY(0 to 0, 0 to k-1);
	variable A : std_logic_vector(m-2 downto 0);  
	begin

	for j in 0 to k-1 loop 
		A := I(((k-j)*(m-1)-1) downto ((k-j-1)*(m-1))); 
		IP1(0, j) := to_integer(unsigned(A));
	end loop;
	
	IP <= IP1;
	
	end process;
	
	
	-- The below process takes the primitive polynomial as input and gives a generator polynomial of n-k+1 length
	process(PP)
	variable G2 : INTEGERARRAY(0 to 0, 0 to (n-k) );
	begin
			
		G2 := GP1(PP => PP);	
		
		GP <= G2;
		
	end process;

	-- The below process takes the input integer array IP, primitive polynomial PP and the generator polynomial GP
	-- as inputs and creates an output array OP
	process(IP, PP, GP)
	variable IP1 : INTEGERARRAY(0 to 0, 0 to n-1);
	variable A1, A2, A3 : INTEGERARRAY(0 to 0, 0 to n-k);
	variable B1, B2, B3 : std_logic_vector( (m-1)-1 downto 0);
	
	begin
	
		IP1 := (others => ( others => 0 ));
		A2 := (others => ( others => 0 ));
		A3 := (others => ( others => 0 ));
		
		-- Creates an array IP1, whose first k elements are elements of the array IP and rest are 0
		for i in 0 to k-1 loop
			IP1(0, n-i-1) := IP(0, i);
		end loop;
		
		
		for i in 0 to n-k loop
			A1(0, i) := IP1(0, n-i-1);
		end loop;
		
		-- Used to do polynomial division, this gives the remainder, A3 when IP1 is divided by GP, and A3 
		-- (excluding the highest indexed element) forms the remaining bits of the encoded codeword 
		for i in 0 to k-1 loop
			
				for j in 0 to n-k loop
					
					A2(0, j) := GAL_MUL(a => GP(0, j), b => A1(0,0), C => PP);
					
					B1((m-1)-1 downto 0) := std_logic_vector(to_unsigned(A1(0, j), m-1));	
					B2((m-1)-1 downto 0) := std_logic_vector(to_unsigned(A2(0, j), m-1));
					
					B3 := B1 XOR B2;
					
					A3(0, j) := to_integer(unsigned(B3));
					
				end loop;	
					
				for l in 0 to (n-k-1) loop
					A1(0, l) := A3(0, l+1);
				end loop;
				A1(0, n-k) := 0;
			
		end loop;
						
		for i in 0 to n-1 loop
			if (i < k) then
				OP(0, i) <= IP(0, i);
			else
				OP(0, i) <= A3(0, i-(k-1));
			end if;
		end loop;
		
	end process;	

	-- The below function is used to convert the output integer array OP, into output vector O, which is the binary
	-- representation of the integers of the array OP, in serial order, where binary representation of each integer
	-- is of m-1 length
	process(OP)
	begin
	
	for i in 0 to n-1 loop
		O( ((n-i)*(m-1) - 1) downto ((n-i-1)*(m-1)) ) <= std_logic_vector(to_unsigned(OP(0, i), m-1));
	end loop;
	
	
	end process;
	
end architecture;
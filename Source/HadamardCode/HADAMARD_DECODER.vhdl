library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity HADAMARD_DECODER is
	generic(
			k : integer := 3; -- No. of output bits
			n : integer := 8); -- Length of codeword, which is 2**k 
	port (
		I : in std_logic_vector (n-1 downto 0);  -- Input vector
		O : out std_logic_vector (k-1 downto 0);	-- Output vector
		error : out std_logic);  -- A bit which will indicate whether the output shown will be valid or not
end entity;

architecture Behavioral of HADAMARD_DECODER is 

type TwoDimensionalArray is array (natural range <>) of std_logic_vector(n-1 downto 0); 
									-- Defining a matrix type which has n columns
type TwoDimensionalArray1 is array (natural range <>) of std_logic_vector(k-1 downto 0); --
									-- Defining a matrix type which has k columns

signal H : TwoDimensionalArray(0 to n-1); -- Defining a Hadamard matrix of nxn size
signal G : TwoDimensionalArray(0 to k-1); -- Defining a generator matrix G of size k x n

signal S : std_logic_vector((n)-1 downto 0);  -- Similar to syndrome vector, it represents the hadamard encoded 
															 -- codeword of the position which is to be changed
signal B2 : std_logic_vector((n)-1 downto 0);  -- The vector whose one bit of input vector is reversed and rest
															  -- is kept same
signal error1 : std_logic;  -- Used for detecting errors in the code
signal error2 : std_logic;  -- There details are mentioned later in the code where they are used
signal err_pos : integer := 0;  -- Used to indicate the error position, the error position in the input signal is
										  -- reversed which helps in getting the correct output

-- The function below performs the matrix multiplication operation, used to multiply matrices A and B of size pxq 
-- and qxr, in this case we have used it to multiply a S1 matrix of 1xk size and G matrix of kxn size which we 
-- used in getting a Hadamard matrix of nxn size

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


-- The function below performs the matrix multiplication operation, used to multiply matrices A and B of size pxq 
-- and qxr, in this case we have used it to multiply a I matrix of 1xn size and H matrix of nxn size to get an 
-- vector B2, of n length

function MAT_MUL1(p : integer := 1;
						q : integer := 3;
						r : integer := 8;
						A : TwoDimensionalArray;
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
	
end function MAT_MUL1;

begin

-- This is a process to create a Generator matrix G, whose rows are such that in bottom row there are alternate 
-- 0s 1s and second last row has alternate '00's and '11's and third last row has alternate '0000's and '1111's
-- similarly the matrix is formed.
	process (I)
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
	
-- This is a proces in which G (created above) and MAT_MUL function is used to get a Hadamard matrix of size nxn
	
	process (G)
	variable o : integer := n;
	variable S1 : std_logic_vector(k-1 downto 0);
	variable S2 : TwoDimensionalArray1(0 to 0);
	begin
	
	-- As i value increases from 0 to n-1, the value of o is decreasing and the binary representaion of o is 
	-- multiplied with Generator Matrix, G which gives the Hadamard codeword for i th row and thus we get a
	-- Hadamard matrix of nxn size
	
	for i in 0 to n-1 loop
			
		S1 := std_logic_vector(to_unsigned(o, k)); -- Here, we are storing the binary reprentation of variable o 
																-- in this vector S1 of length k
			
	-- Used for converting the 1-dimensional array or vector S1 to 2-dimensional matrix S2 of 1xk size
		
		for j in 0 to k-1 loop
			S2(0)((k-1)-j) := S1(j); 
		end loop;
	
		H(i) <= MAT_MUL(p => 1, q => k, r => n, A => S2, B => G); 
		o := o - 1;
		
	end loop;
		
	end process;

-- This is a proces in which input vector I, H (created above) and MAT_MUL1 function is used to get a vector S 
-- of n length
	
	process(I, H)
	variable I1 : TwoDimensionalArray(0 downto 0);
	begin
	
	-- Convert the 1-dimensional input array or input vector I to 2-dimensional matrix I1 of 1xn size
	for j in 0 to n-1 loop
		I1(0)(j) := I(j);
	end loop;
	
	S <= MAT_MUL1(p => 1, q => n, r => n, A => I1, B => H);
	
	end process;
	
-- In the below process, S, H and I are used to get a vector B2 and signals error1 and error2 and a signal 
-- err_pos which indicates error position
	
	process(S, H, I)
	variable a : integer := 0; -- variable a is initiated to 0, which stores the value of error position
	begin
	
	-- This loop helps us in getting error position, it matches S vector with the i th row of H matrix and 
	-- gives signal a the error position value
	
	for i in 0 to n-1 loop
		if ( S = H(i) ) then
			a := i;
			exit;
		else
			a := 0;
		end if;
	end loop;
	
-- This loop helps in indicating whether there are 0 errors or 1 error or n errors (8 in this case) in the 
-- input vector. If value of error1 is 0 that indicates that there is not any single or multiple errors 
-- except n bit error ( i.e. the signal is reversed completely) and if it is 1 then it indicates that there
-- more than possible errors in this, it corrects the input vector considering there is only one error.
-- If error2 is 1, it indicates that there are n bits errors ( or entire signal is reversed) and if it is 0
-- it indicates that the signal is not completely reversed.

	for j in 0 to n-1 loop
		if (I = H(j)) then
			error1 <= '0';
			error2 <= '0';
			exit;
		elsif (I = NOT(H(j))) then
			error2 <= '1';
			error1 <= '0';
			exit;
		else 
			error1 <= '1';
			error2 <= '0';
		end if;
	end loop;
	
	err_pos <= a; -- The signal is gievn the error position value
	
	end process;
	
	process(error1, error2, err_pos, I)
	begin
	
	if (error1 <= '0' AND error2 <= '0') then
		B2 <= I;						-- If error1 is 0 and error2 is 0 this indicates that there are 0 errors in the
										-- received codeword and the input signal is received correctly
	elsif (error1 <= '0' AND error2 <= '1') then 
		B2 <= NOT(I);				-- If error1 is 0 and error2 is 1 this indicates that the input signal received
										-- has n errors and all the bits should be reversed to egt correct output signal
	else
		for j in 0 to n-1 loop			-- This loop works considering that there is atleast 1 error and it reverses 
			if (err_pos = j) then		-- one bit of the received signal and gives B2 vector keeping rest signal
				B2(j) <= NOT (I(j));		-- as it is
			else
				B2(j) <=  (I(j));
			end if;
		end loop;
	end if;
	
	end process;
	
	process(B2, H, error1, error2)
	begin
	
-- This loop checks if B2 signal or reverse of the signal is matching to i th row of Hadamard matrix, it converts 
-- the i th position to a 3 bit vector B4 as this is the signal that should be recieved considering there are 0 
-- 1 or n-1 or n bit errors in the signal and the value of the error signal is 0 which indicates the output 
--received after this is correct and when there is a signal which has errors of other type than mentioned 
-- above, then it cannot be corrected and B4 vector shows binary representation of 0 in three bits.
	
	for i in 0 to n-1 loop
		if ( ( B2 = H(i) ) OR ( B2 = NOT(H(i)) ) ) then
			O <= std_logic_Vector(to_unsigned(i, k));
			error <= '0';
			exit;
		else
			O <= std_logic_Vector(to_unsigned(0, k));
			error <= '1';
		end if;
	end loop;
	
	end process;
	
end architecture;

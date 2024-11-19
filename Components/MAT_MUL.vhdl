library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MAT_MUL is
	generic( 
			m : integer := 1;
			n : integer := 4;
			k : integer := 7);
   port (
		A : in  std_logic_vector (m*n-1 downto 0);
      B : in  std_logic_vector (n*k-1 downto 0);
      C : out std_logic_vector (m*k-1 downto 0));
end entity;

architecture Behavioral of MAT_MUL is

type TwoDimensionalArray1 is array (0 to m-1, 0 to n-1) of std_logic;
type TwoDimensionalArray2 is array (0 to n-1, 0 to k-1) of std_logic;
type TwoDimensionalArray3 is array (0 to m-1, 0 to k-1) of std_logic;
signal A1 : TwoDimensionalArray1;
signal B1 : TwoDimensionalArray2;
signal C1 : TwoDimensionalArray3;

begin
	
	process (A)
	begin
    -- Convert the 1-dimensional input array or input vector A to 2-dimensional matrix A1
		for i in 0 to m-1 loop
			for j in 0 to n-1 loop
				A1(i, j) <= A((i * n) + j);
			end loop;
		end loop;
	end process;
	
	process (B)
   begin
    -- Convert the 1-dimensional input array or input vector B to 2-dimensional matrix B1
		for i in 0 to n-1 loop
			for j in 0 to k-1 loop
				B1(i, j) <= B((i * k) + j);
			end loop;
		end loop;
	end process;
	
	process (A1, B1, C1)
	variable temp : TwoDimensionalArray3;
	variable sum : TwoDimensionalArray3;
	begin
	
	for i in 0 to m-1 loop
		for j in 0 to k-1 loop
			temp := (others => (others => '0'));
		  
			for k in 0 to n-1 loop
				temp(i,j) := temp(i,j) XOR (A1(i,k) AND B1(k,j));
			end loop;

			sum(i,j) := temp(i,j);
		end loop;
   end loop;
		
	C1 <= sum;

	end process;
	
	process (C1)
   begin
    -- Convert the 2-dimensional matrix C1 to 1-dimensional output array or vector C
		for i in 0 to m-1 loop
			for j in 0 to k-1 loop
				C((i * k) + j) <= C1(i, j);
			end loop;
		end loop;
	end process;

end Behavioral;
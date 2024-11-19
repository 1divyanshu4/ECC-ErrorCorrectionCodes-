library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MAT_ADD is
	generic( 
			m : integer := 4;
			n : integer := 4);
   port (
		A : in  std_logic_vector (m*n-1 downto 0);
      B : in  std_logic_vector (m*n-1 downto 0);
      C : out std_logic_vector (m*n-1 downto 0);
		Carry : out std_logic);
end entity;

architecture Behavioral of MAT_ADD is

type TwoDimensionalArray is array (0 to m-1, 0 to n-1) of std_logic;
signal A1, B1, C1, Carry1 : TwoDimensionalArray;

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
		for i in 0 to m-1 loop
			for j in 0 to n-1 loop
				B1(i, j) <= B((i * n) + j);
			end loop;
		end loop;
	end process;
	
	process (C1)
	begin
	
		for i in 0 to m-1 loop 
			for j in 0 to n-1 loop
					C1(i,j) <= '0';
					Carry1(i,j) <= '0';
			end loop;
		end loop;
		
		for i in 0 to m-1 loop 
			for j in 0 to n-1 loop
				if ((j = 0) AND (i = 0)) then
					Carry1(i,j) <= ((A1(i,j)) AND (B1(i,j)));
				elsif ((j = 0) AND (i /= 0)) then
					Carry1(i,j) <= ((A1(i,j)) AND (B1(i,j))) OR (Carry1(i-1, n-1) AND (A1(i,j) XOR B1(i,j)));
				elsif ((j /= 0) AND (i /= 0)) then
					Carry1(i,j) <= ((A1(i,j)) AND (B1(i,j))) OR (Carry1(i,j-1) AND ((A1(i,j)) XOR (B1(i,j))));
				end if;
			end loop;
		end loop;

		for i in 0 to m-1 loop 
			for j in 0 to n-1 loop
				if ((j = 0) AND (i = 0)) then
					C1(i,j) <= A1(i,j) XOR B1(i,j);
				elsif ((j = 0) AND (i /= 0)) then
					C1(i,j) <= Carry1(i-1, n-1) XOR (A1(i,j) XOR B1(i,j));
				elsif ((j /= 0) AND (i /= 0)) then
					C1(i,j) <= Carry1(i,j-1) XOR ((A1(i,j)) XOR (B1(i,j)));
				end if;
			end loop;
		end loop;
		
	end process;
	
	process (C1)
   begin
    -- Convert the 1-dimensional input array or input vector B to 2-dimensional matrix B1
		for i in 0 to m-1 loop
			for j in 0 to n-1 loop
				C((i * n) + j) <= C1(i, j);
			end loop;
		end loop;
	end process;
	
	Carry <= A1(3,3) AND B1(3,3);

end Behavioral;

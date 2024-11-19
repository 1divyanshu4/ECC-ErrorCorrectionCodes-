library ieee;
use ieee.std_logic_1164.all;

entity Generic_HCE is
	generic (
		 n : positive := 4;  -- number of data bits
		 k : positive := 3  -- number of parity bits
	  );
	  port (
		 A : in std_logic_vector(n-1 downto 0);  -- input data
		 B : out std_logic_vector(n+k-1 downto 0));  -- encoded output
end entity;

architecture behavioral of Generic_HCE is
signal D : std_logic_vector(n+k-1 downto 0);
signal M1 : std_logic_vector(k-1 downto 0);

begin

	process(A)
	variable D1 : std_logic_vector(n+k-1 downto 0);
	variable x : integer;
	begin

	x := 0; -- To set x as 0 for every input, as we need x to start from 0 whenever we change iinput
	
-- For creating a variable vector D of n+k bits (say, of 15 bits) from the input signal A of n bits (of 11
-- bits (if D is of 15 bits)) such that the position in the power of 2 is 0 to insert parity bits there and 
--	rest are the bits from input signal A
	for j in 0 to n+k-1 loop
		if ( j = 2**x - 1 ) then 
			D1(j) := '0';
			x := x + 1;
		else
			D1(j) := A(j-x);
		end if;
	end loop;
	D <= D1;
	end process;
	
	process(A, D)
	variable C : std_logic_vector(k-1 downto 0);
	begin
	
-- initialize the parity bits to 0
	C := (others => '0');

-- For calculating the parity bits
   for i in 0 to k-1 loop
      for j in 0 to n+k-1 loop
         if (j+1)/(2**(i)) mod 2 = 1 then
            C(i) := C(i) XOR D(j);
         end if;
      end loop;
   end loop;

	M1 <= C;
	
	end process;
	
	process(M1, D)
	variable B1 : std_logic_vector(n+k-1 downto 0);
	variable m : integer;
	begin
	
	m := 0; -- To set m as 0 for every input, as we need m to start from 0 whenever we change input

-- For creating the output signal with parity bits at the position in power of 2 and rest as the bits from input 
-- signal D
	for j in 0 to n+k-1 loop
		if ( j = 2**m - 1 ) then 
			B1(j) := M1(m);
			m := m + 1;
		else
			B1(j) := D(j);
		end if;
	end loop;
	B <= B1;
	end process;
	
end Behavioral;

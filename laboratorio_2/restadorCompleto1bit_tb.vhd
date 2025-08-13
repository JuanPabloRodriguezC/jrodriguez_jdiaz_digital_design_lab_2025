library IEEE; 
use IEEE.STD_LOGIC_1164.all; -- importar librerias

entity restadorCompleto1bit_tb is 
end;

architecture sim of restadorCompleto1bit_tb is
component restadorCompleto1bit
port (
        A, B, Cin : in std_logic; --in de input
        S, Cout : out std_logic --out de output
    );
end component; --referenciamos los puertos a probar

signal AS, BS, CinS: std_logic; -- declaramos las señales
signal SS, CoutS: std_logic; -- declaramos las señales


begin
-- instancia device under test
dut: restadorCompleto1bit port map(

        A => AS,
        B => BS,
        Cin => CinS,
        S => SS,
        Cout => CoutS
    ); -- definimos las igualdades de las señales

process 
    begin 
	 
	     AS <= '0'; BS <= '0'; CinS <= '0'; -- inicializamos las señales
		  wait for 20 ns; -- esperamos 20 ns
        AS <= '1'; BS <= '0'; CinS <= '0'; -- cambiamos las señales
		  wait for 20 ns; 
        AS <= '0'; BS <= '1'; CinS <= '0'; wait for 20 ns;
        AS <= '1'; BS <= '1'; CinS <= '0'; wait for 20 ns;
        AS <= '0'; BS <= '0'; CinS <= '1'; wait for 20 ns;
        AS <= '1'; BS <= '0'; CinS <= '1'; wait for 20 ns;
        AS <= '0'; BS <= '1'; CinS <= '1'; wait for 20 ns;
        AS <= '1'; BS <= '1'; CinS <= '1'; wait for 20 ns;

		wait;
	end process;
end;
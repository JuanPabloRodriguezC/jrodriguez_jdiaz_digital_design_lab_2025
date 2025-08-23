library IEEE;
use IEEE.STD_LOGIC_1164.all; -- importar librerias

entity restadorCompleto4bits_tb is -- entidad que forma parte de la estructura grande

end restadorCompleto4bits_tb;

architecture sim of restadorCompleto4bits_tb is
    component restadorCompleto4bits -- componente que vamos a usar
        port (
            A1, B1: in std_logic_vector(3 downto 0); --in de input vector
            Cin1 : in std_logic; -- in de input
            S1 : out std_logic_vector(3 downto 0); -- out de output vector
            Cout1 : out std_logic -- out de output
        );
    end component; -- definimos el componente

    signal A1, B1: std_logic_vector(3 downto 0) := (others => '0'); -- declaramos las señales de entrada
    signal Cin1: std_logic := '0'; -- declaramos las señales de entrada
    signal S1: std_logic_vector(3 downto 0); -- declaramos
    signal Cout1: std_logic ;

    begin 

    dut : restadorCompleto4bits port map(
        A1 => A1,
        B1 => B1,
        Cin1 => Cin1,
        S1 => S1,
        Cout1 => Cout1
    ); -- instanciamos el componente

    process 
        begin 
        A1 <= "0000"; B1 <= "0000"; Cin1 <= '0'; -- inicializamos las señales
        wait for 20 ns; -- esperamos 20 ns
        A1 <= "0000"; B1 <= "0001"; Cin1 <= '0'; -- cambiamos las señales
        wait for 20 ns; -- esperamos 20 ns
        A1 <= "0001"; B1 <= "0000"; Cin1 <= '0'; -- cambiamos las señales
        wait for 20 ns; -- esperamos 20 ns
        A1 <= "0001"; B1 <= "0001"; Cin1 <= '0'; -- cambiamos las señales
        wait for 20 ns; -- esperamos 20 ns
		  wait;
	end process;
	end sim;
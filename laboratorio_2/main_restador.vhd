library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity main_restador is 
	port(
		switch : in std_logic_vector(9 downto 0); 
		leds : out std_logic_vector(9 downto 0);
		hex: out std_logic_vector(6 downto 0)
	);
end entity;

architecture struct of main_restador is 
	signal A, B : std_logic_vector(3 downto 0);
	signal Cin : std_logic;
	signal S : std_logic_vector(3 downto 0);
	signal Cout : std_logic;
begin

-- Establece switches

A <= switch(7 downto 4); --4 bits de entrada
B <= switch(3 downto 0); --4 bits de entrada
Cin <= switch(8); --1 bit de entrada

-- Restador de 4 bits 

u_restador : entity work.restadorCompleto4bits -- u_xx es el identificador de la instancia
	port map(A1 => A, B1=> B,Cin1 => Cin ,S1 => S, Cout1 => Cout); -- instancia el restador completo, A1 es del restador y A es de main

-- Muestra en 7 segmentos

u_hex : entity work.segmentos7 -- u_xx es el identificador de la instancia
	port map(data => S,
        segments => hex); -- instancia el 7 segmentos con los datos del restador
		  
-- LEDS para binario

leds(3 downto 0) <= S; -- muestra la salida en binario (4bits)
leds(9) <= Cout; -- muestra si hay carry out
leds(8 downto 4) <= (others => '0');

end architecture;
library IEEE;
use IEEE.STD_LOGIC_1164.all; -- importar librerias

entity restadorCompleto4bits is -- entidad que forma parte de la estructura grande
-- realiza la operacion B - A con un bit de acarreo Cin
    port (
        A1, B1: in std_logic_vector(3 downto 0); -- in de input vector
        Cin1 : in std_logic; -- in de input
        S1 : out std_logic_vector(3 downto 0); -- out de output vector
        Cout1 : out std_logic -- out de output
    );
	 
	 end restadorCompleto4bits; 

    architecture struct of restadorCompleto4bits is -- arquitectura de la entidad cabeza
    component restadorCompleto1bit is 
        port (
            A, B, Cin : in std_logic; --in de input
            S, Cout : out std_logic --out de output
        );
    end component; -- definimos el componente que vamos a usar

    signal aux: std_logic_vector(3 downto 1); -- declaramos una señal que nos ayude a pasar el bit por los puertos

    begin

        FS0: restadorCompleto1bit port map(
            A => A1(0),
            B => B1(0),
            Cin => Cin1,
            S => S1(0),
            Cout => aux(1)
        ); -- instanciamos el primer bit

        FS1: restadorCompleto1bit port map(
            A => A1(1),
            B => B1(1),
            Cin => aux(1),
            S => S1(1),
            Cout => aux(2)
        ); -- instanciamos el segundo bit

        FS2: restadorCompleto1bit port map(
            A => A1(2),
            B => B1(2),
            Cin => aux(2),
            S => S1(2),
            Cout => aux(3)
        ); -- instanciamos el tercer bit

        FS3: restadorCompleto1bit port map(
            A => A1(3),
            B => B1(3),
            Cin => aux(3),
            S => S1(3),
            Cout => Cout1
        ); -- instanciamos el cuarto bit

    end struct; -- fin de la arquitectura 

library IEEE;
use IEEE.STD_LOGIC_1164.all; -- importa librerias

entity restadorCompleto1bit is -- entidad que forma parte de la estructura grande
--realiza la operacion B - A con un bit de acarreo Cin. B es el minuendo, A el sustraendo
    port (
        A, B, Cin : in std_logic; --in de input
        S, Cout : out std_logic --out de output
    );
end;

    architecture Behavioral of restadorCompleto1bit is -- arquitectura de la entidad (lo que hace el modulo)
    begin
        S <= ((B xor A) xor Cin); -- salida S es la suma xor de A, B y Cin (ver diseño)

        Cout <= ((Cin and not(B)) or (Cin and A) or (not(B) and A)); -- segun la ecuacion determinada (ver diseño)
    end Behavioral; -- fin de la arquitectura

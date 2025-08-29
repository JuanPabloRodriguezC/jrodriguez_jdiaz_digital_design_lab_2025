`timescale 1ns/1ps

module alu_tb;

    parameter WIDTH = 4;

    // Entradas a probar
	 
    logic [WIDTH-1:0] A, B;
    logic boton0, boton1, boton2, boton3;
	 logic Cin;

    // Salidas
    logic [WIDTH-1:0] S;
    logic Cout;

    // Instancia de la ALU
    alu #(.WIDTH(WIDTH)) dut (
        .A(A),
        .B(B),
		  
        .boton0(boton0),
		  .boton1(boton1),
		  .boton2(boton2),
		  .boton3(boton3),
  
        .Cin(Cin),
        .S(S),
        .Cout(Cout)
    );

    // Proceso de prueba
    initial begin

        // Caso 1: Suma (3 + 6)
        A = 4'b0011; B = 4'b0110; Cin = 0;
		  boton3 = 0; boton2 = 0; boton1 = 0; boton0 = 1; #10;
		  assert (S === 4'b1001) else $error("suma 3 + 6 failed);
		  assert (Cout === 0) else $error("carry 3+6 failed);
		  
        
        // Caso 2: Suma con carry (15 + 1)
        A = 4'b1111; B = 4'b0001; Cin = 0;
		  boton3 = 0; boton2 = 0; boton1 = 0; boton0 = 1; #10;
		  assert (S === 4'b0000) else $error("suma 15 + 1 failed);
		  assert (Cout === 1) else $error("carry 15 + 1 failed);
        

        // Caso 3: Resta (8 - 5)
        A = 4'b1000; B = 4'b0101; Cin = 0;
		  boton3 = 0; boton2 = 0; boton1 = 1; boton0 = 0; #10;
		  assert (S === 4'b0011) else $error("resta 8 - 5 failed);
		  assert (Cout === 0) else $error("carry 8-5 failed);
        

        // Caso 4: Resta con resultado negativo (3 - 10)
        A = 4'b0011; B = 4'b1010; Cin = 0;
        boton3 = 0; boton2 = 0; boton1 = 1; boton0 = 0; #10;
		  assert (S === 4'1001) else $error("resta 3 - 10 failed);
		  assert (Cout === 1) else $error("carry 3-10 failed);
    end

endmodule

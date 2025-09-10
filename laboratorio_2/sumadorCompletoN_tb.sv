`timescale 1ns/1ps

module sumadorCompletoN_tb;

    parameter WIDTH = 8; // cambiar a gusto (recordar cambiar los bits)

    // Inputs a probar
    logic [WIDTH-1:0] A, B;
    logic Cin;
    logic [WIDTH-1:0] S;
    logic Cout;

    // Instancia del DUT (Device Under Test)
    sumadorCompletoN #(.WIDTH(WIDTH)) dut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .S(S),
        .Cout(Cout)
    );

    // Proceso de prueba
    initial begin
        $display("=== TEST SUMADOR N=%0d BITS ===", WIDTH);
        $display("   Tiempo |      A   +   B   +  Cin = S (Cout)");
        $display("--------------------------------------------------");

        // Caso 1
        A = 8'b00000011; B = 8'b00000110; Cin = 0; #10; 
        $display("%8t | %0d + %0d + %0d = %0d (Cout=%b)", 
                  $time, A, B, Cin, S, Cout);

        // Caso 2
        A = 8'b11111111; B = 8'b00000001; Cin = 0; #10;
        $display("%8t | %0d + %0d + %0d = %0d (Cout=%b)", 
                  $time, A, B, Cin, S, Cout);

        // Caso 3
        A = 8'b00000101; B = 8'b10000000; Cin = 0; #10;
        $display("%8t | %0d + %0d + %0d = %0d (Cout=%b)", 
                  $time, A, B, Cin, S, Cout);

        // Caso 4
        A = 8'b10101010; B = 8'b10101010; Cin = 0; #10;
        $display("%8t | %0d + %0d + %0d = %0d (Cout=%b)", 
                  $time, A, B, Cin, S, Cout);

        // Fin de simulación
        $finish;
    end

endmodule


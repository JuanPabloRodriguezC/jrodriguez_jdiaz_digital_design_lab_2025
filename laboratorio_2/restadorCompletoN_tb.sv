`timescale 1ns/1ps

module restadorCompletoN_tb;

    parameter WIDTH = 4; // cambiar esto para probar diferentes anchos

    // Inputs a probar
    logic [WIDTH-1:0] A, B;
    logic Cin;
    logic [WIDTH-1:0] S;
    logic Cout;

    // Instancia del DUT (Device Under Test)
    restadorCompletoN #(.WIDTH(WIDTH)) dut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .S(S),
        .Cout(Cout)
    );

    // Proceso de prueba
    initial begin
        $display("=== TEST RESTADOR N=%0d BITS ===", WIDTH);
        $display("   Tiempo |      B   -   A   - Cin = S (Cout)");
        $display("--------------------------------------------------");

        // Caso 1
        A = 4'b0011; B = 4'b0110; Cin = 0; #10;
        $display("%8t | %0d - %0d - %0d = %0d (Cout=%b)", $time, B, A, Cin, S, Cout);

        // Caso 2
        A = 4'b1111; B = 4'b0001; Cin = 0; #10;
        $display("%8t | %0d - %0d - %0d = %0d (Cout=%b)", $time, B, A, Cin, S, Cout);

        // Caso 3
        A = 4'b0101; B = 4'b1000; Cin = 0; #10;
        $display("%8t | %0d - %0d - %0d = %0d (Cout=%b)", $time, B, A, Cin, S, Cout);

        // Caso 4
        A = 4'b1010; B = 4'b1010; Cin = 0; #10;
        $display("%8t | %0d - %0d - %0d = %0d (Cout=%b)", $time, B, A, Cin, S, Cout);

        // Fin de simulación
        $finish;
    end

endmodule
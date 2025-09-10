// Testbench para el multiplicador combinacional
module tb_multiplicador;
    parameter WIDTH = 4; 
    
    logic [WIDTH-1:0] multiplicando;
    logic [WIDTH-1:0] multiplicador;
    logic [2*WIDTH-1:0] resultado;
    
    
    multiplicador #(.WIDTH(WIDTH)) dut1 (
        .multiplicando(multiplicando),
        .multiplicador(multiplicador),
        .resultado(resultado)
    );
    
    initial begin
        test_mult(4'd3, 4'd5);   // 3 × 5 = 15
        test_mult(4'd7, 4'd4);   // 7 × 4 = 28
        test_mult(4'd0, 4'd15);  // 0 × 15 = 0
        test_mult(4'd15, 4'd1);  // 15 × 1 = 15
        test_mult(4'd8, 4'd2);   // 8 × 2 = 16
        test_mult(4'd15, 4'd15); // 15 × 15 = 225    
        $finish;
    end
    
    // Task para probar multiplicación
    task test_mult(input [WIDTH-1:0] a, input [WIDTH-1:0] b);
        integer expected;
        begin
            multiplicando = a;
            multiplicador = b;
            expected = a * b;
            
            #1;
            
            $display("Test: %2d × %2d = %3d | %s", a, b, expected, ((resultado == expected)) ? "PASS" : "FAIL");
            
            if (resultado != expected)
                $display("  ERROR: Expected %d, got %d", expected, resultado);
            
            
            #10;
        end
    endtask
endmodule
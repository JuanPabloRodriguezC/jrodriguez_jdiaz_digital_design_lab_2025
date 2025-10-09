// Generador de números pseudo-aleatorios usando LFSR
// Genera continuamente valores random para random_card1 y random_card2
module randomGenerator(
    input  logic       clk,
    input  logic       rst,
    output logic [3:0] random_card1,  // Valor 0-15
    output logic [3:0] random_card2   // Valor 0-15
);
    // LFSR de 16 bits para mayor período
    // Polinomio: x^16 + x^15 + x^13 + x^4 + 1
    logic [15:0] lfsr1, lfsr2;
    logic feedback1, feedback2;
    
    // Feedback para LFSR1
    assign feedback1 = lfsr1[15] ^ lfsr1[14] ^ lfsr1[12] ^ lfsr1[3];
    
    // Feedback para LFSR2 (diferente configuración inicial)
    assign feedback2 = lfsr2[15] ^ lfsr2[13] ^ lfsr2[11] ^ lfsr2[1];
    
    // LFSR1 - para random_card1
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Semilla inicial no puede ser 0
            lfsr1 <= 16'hACE1;  // Valor inicial arbitrario
        end else begin
            // Shift y XOR feedback
            lfsr1 <= {lfsr1[14:0], feedback1};
        end
    end
    
    // LFSR2 - para random_card2
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Semilla inicial diferente
            lfsr2 <= 16'h5EED;  // Otra semilla
        end else begin
            // Shift y XOR feedback
            lfsr2 <= {lfsr2[14:0], feedback2};
        end
    end
    
    // Extraer valores de 4 bits (0-15) de los LFSRs
    // Usar bits intermedios para mejor distribución
    assign random_card1 = lfsr1[7:4];
    assign random_card2 = lfsr2[11:8];
endmodule
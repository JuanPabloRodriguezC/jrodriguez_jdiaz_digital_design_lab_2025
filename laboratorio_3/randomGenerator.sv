// Generador de números pseudo-aleatorios usando LFSR
// Genera valores random válidos (cartas no encontradas)
module randomGenerator(
    input  logic       clk,
    input  logic       rst,
    input  logic [15:0] cards_matched,  // Cartas ya encontradas (no seleccionables)
    output logic [3:0] random_card1,    // Valor 0-15 (carta disponible)
    output logic [3:0] random_card2     // Valor 0-15 (carta disponible)
);
    // LFSR de 16 bits para mayor período
    // Polinomio: x^16 + x^15 + x^13 + x^4 + 1
    logic [15:0] lfsr1, lfsr2;
    logic feedback1, feedback2;
    
    // Valores raw del LFSR (antes de validación)
    logic [3:0] lfsr1_raw, lfsr2_raw;
    
    // Feedback para LFSR1
    assign feedback1 = lfsr1[15] ^ lfsr1[14] ^ lfsr1[12] ^ lfsr1[3];
    
    // Feedback para LFSR2 (diferente configuración inicial)
    assign feedback2 = lfsr2[15] ^ lfsr2[13] ^ lfsr2[11] ^ lfsr2[1];
    
    // LFSR1 - para random_card1
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr1 <= 16'hACE1;  // Semilla inicial
        end else begin
            lfsr1 <= {lfsr1[14:0], feedback1};
        end
    end
    
    // LFSR2 - para random_card2
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr2 <= 16'h5EED;  // Semilla diferente
        end else begin
            lfsr2 <= {lfsr2[14:0], feedback2};
        end
    end
    
    // Extraer valores raw de 4 bits (0-15)
    assign lfsr1_raw = lfsr1[7:4];
    assign lfsr2_raw = lfsr2[11:8];
    
    // Validar que las cartas no estén ya encontradas
    // Si la carta está encontrada, buscar la siguiente disponible
    always_comb begin
        automatic logic [3:0] temp1, temp2;
        automatic integer i;
        
        // Validar random_card1
        temp1 = lfsr1_raw;
        for (i = 0; i < 16; i = i + 1) begin
            if (!cards_matched[temp1]) begin
                break;  // Encontró carta disponible
            end else begin
                temp1 = temp1 + 4'd1;  // Siguiente carta
                if (temp1 > 4'd15)
                    temp1 = 4'd0;  // Wrap around
            end
        end
        random_card1 = temp1;
        
        // Validar random_card2 (diferente a card1)
        temp2 = lfsr2_raw;
        for (i = 0; i < 16; i = i + 1) begin
            if (!cards_matched[temp2] && temp2 != random_card1) begin
                break;  // Encontró carta disponible y diferente
            end else begin
                temp2 = temp2 + 4'd1;  // Siguiente carta
                if (temp2 > 4'd15)
                    temp2 = 4'd0;  // Wrap around
            end
        end
        random_card2 = temp2;
    end
    
endmodule
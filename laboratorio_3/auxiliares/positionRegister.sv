module positionRegister(
    input  logic       clk,
    input  logic       rst,
    input  logic       load_carta1,
    input  logic       load_carta2,
    input  logic       use_random,
    input  logic       selector_carta,  // Nueva señal
    input  logic [3:0] cursor_pos,
    input  logic [3:0] random_card1,
    input  logic [3:0] random_card2,
    
    output logic [3:0] carta1_pos,
    output logic [3:0] carta2_pos
);
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            carta1_pos <= 4'h0;
            carta2_pos <= 4'h0;
        end else begin
            if (use_random) begin
                // Selección aleatoria tiene prioridad
                if (selector_carta == 1'b0) begin
                    // Timeout en S0: seleccionar AMBAS cartas random
                    carta1_pos <= random_card1;
                    carta2_pos <= random_card2;
                end else begin
                    // Timeout en S1: carta1 YA está seleccionada, solo carta2
                    // NO tocar carta1_pos
                    carta2_pos <= random_card1;  // Usar random_card1 para carta2
                end
            end else begin
                // Cargar posiciones del cursor
                if (load_carta1)
                    carta1_pos <= cursor_pos;
                if (load_carta2)
                    carta2_pos <= cursor_pos;
            end
        end
    end
endmodule
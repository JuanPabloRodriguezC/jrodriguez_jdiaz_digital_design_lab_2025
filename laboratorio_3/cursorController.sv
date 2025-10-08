// Controlador de cursor para navegar entre cartas
module cursorController(
    input  logic       clk,
    input  logic       rst,
    
    // Botones de dirección
    input  logic       btn_up,
    input  logic       btn_down,
    input  logic       btn_left,
    input  logic       btn_right,
    input  logic       btn_select,
    
    // FSM control
    input  logic       selector_carta,  // 0=selecting card1, 1=selecting card2
    
    // Salidas
    output logic [3:0] cursor_pos,      // Posición actual del cursor
    output logic       carta_recibida,  // Pulso cuando se selecciona una carta
    output logic [3:0] carta1_id,       // ID de la primera carta seleccionada
    output logic [3:0] carta2_id        // ID de la segunda carta seleccionada
);

    // Registro de posición del cursor
    logic [3:0] cursor_reg;
    logic [3:0] carta1_reg;
    logic [3:0] carta2_reg;
    
    // Detección de flancos para los botones
    logic [4:0] btn_prev;
    logic btn_up_edge, btn_down_edge, btn_left_edge, btn_right_edge, btn_select_edge;
    
    // Debounce counter
    logic [19:0] debounce_counter;
    logic debounce_ready;
    
    // Debounce: esperar ~10ms entre pulsaciones (500k ciclos @ 50MHz)
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            debounce_counter <= 20'd0;
            debounce_ready <= 1'b1;
        end else begin
            if (debounce_counter > 0) begin
                debounce_counter <= debounce_counter - 1;
                debounce_ready <= 1'b0;
            end else begin
                debounce_ready <= 1'b1;
            end
            
            // Iniciar debounce cuando se presiona cualquier botón
            if ((btn_up_edge || btn_down_edge || btn_left_edge || btn_right_edge || btn_select_edge) && debounce_ready) begin
                debounce_counter <= 20'd500000;  // ~10ms
            end
        end
    end
    
    // Detección de flancos de subida
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_prev <= 4'b0000;
        end else begin
            btn_prev <= {btn_select, btn_right, btn_left, btn_down, btn_up};
        end
    end
    
    assign btn_up_edge     = btn_up     && !btn_prev[0] && debounce_ready;
    assign btn_down_edge   = btn_down   && !btn_prev[1] && debounce_ready;
    assign btn_left_edge   = btn_left   && !btn_prev[2] && debounce_ready;
    assign btn_right_edge  = btn_right  && !btn_prev[3] && debounce_ready;
    assign btn_select_edge = btn_select && !btn_prev[4] && debounce_ready;
    
    // Lógica de movimiento del cursor (Grid 4x4)
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cursor_reg <= 4'd0;  // Inicia en posición 0 (esquina superior izquierda)
        end else begin
            if (btn_up_edge) begin
                // Mover arriba: restar 4, pero no pasar de 0
                if (cursor_reg >= 4)
                    cursor_reg <= cursor_reg - 4'd4;
            end
            else if (btn_down_edge) begin
                // Mover abajo: sumar 4, pero no pasar de 15
                if (cursor_reg < 12)
                    cursor_reg <= cursor_reg + 4'd4;
            end
            else if (btn_left_edge) begin
                // Mover izquierda: restar 1, pero no cambiar de fila
                if (cursor_reg[1:0] != 2'b00)
                    cursor_reg <= cursor_reg - 4'd1;
            end
            else if (btn_right_edge) begin
                // Mover derecha: sumar 1, pero no cambiar de fila
                if (cursor_reg[1:0] != 2'b11)
                    cursor_reg <= cursor_reg + 4'd1;
            end
        end
    end
    
    // Señal de selección (pulso de un ciclo)
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            carta1_reg <= 4'h0;
            carta2_reg <= 4'h0;
            carta_recibida <= 1'b0;
        end else begin
            carta_recibida <= 1'b0;  // Default: no pulse
            
            if (btn_select_edge) begin
                if (selector_carta == 1'b0) begin
                    // Selecting first card
                    carta1_reg <= cursor_reg;
                    carta_recibida <= 1'b1;
                end else begin
                    // Selecting second card
                    carta2_reg <= cursor_reg;
                    carta_recibida <= 1'b1;
                end
            end
        end
    end
    
    // Salidas
    assign cursor_pos = cursor_reg;
    assign carta1_id = carta1_reg;
    assign carta2_id = carta2_reg;

endmodule
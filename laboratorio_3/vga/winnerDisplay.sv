// winnerDisplay.sv - Renderiza el mensaje de ganador en español (corregido)
module winnerDisplay(
    input logic clk,
    input  logic [9:0] x,
    input  logic [9:0] y,
    input  logic       game_over,
    input  logic [3:0] puntaje1,
    input  logic [3:0] puntaje2,
    output logic       text_pixel    // 1 = draw text, 0 = transparent
);

    // Determinar ganador
    logic player1_wins, player2_wins, is_tie;
    logic [3:0] winner_num;  // 1 o 2
    
    assign player1_wins = game_over && (puntaje1 > puntaje2);
    assign player2_wins = game_over && (puntaje2 > puntaje1);
    assign is_tie = game_over && (puntaje1 == puntaje2);
    assign winner_num = player1_wins ? 4'd1 : 4'd2;
    
    // Coordenadas relativas para el texto centrado
    localparam [9:0] TEXT_CENTER_X = 10'd320;
    localparam [9:0] TEXT_CENTER_Y = 10'd250;
    
    // Dimensiones de caracteres (8x8 pixels, escalado 3x = 24x24)
    localparam CHAR_WIDTH = 24;
    localparam CHAR_HEIGHT = 24;
    localparam SCALE = 3;
    
    // Para "GANA JUGADOR X": 14 caracteres = 14 * 24 = 336 pixels
    // Centrar: offset = -168 (mitad de 336)
    localparam WINNER_CHARS = 14;
    localparam WINNER_WIDTH = WINNER_CHARS * CHAR_WIDTH;  // 336
    
    // Para "EMPATE": 6 caracteres = 6 * 24 = 144 pixels
    // Centrar: offset = -72 (mitad de 144)
    localparam TIE_CHARS = 6;
    localparam TIE_WIDTH = TIE_CHARS * CHAR_WIDTH;  // 144
    
    logic signed [10:0] rel_x, rel_y;
    logic [3:0] char_index;
    logic [2:0] char_row, char_col;
    logic [7:0] char_pattern;
    logic [4:0] x_in_char;  // Posición X dentro del carácter (0-23)
    logic [9:0] max_width;
    
    always_ff @(posedge clk) begin
        text_pixel <= 1'b0;
        
        if (game_over) begin
            // Determinar ancho del mensaje según si es empate o ganador
            if (is_tie) begin
                // Centrar "EMPATE" (144 pixels de ancho)
                rel_x = $signed(x) - $signed(TEXT_CENTER_X) + $signed(11'd72);
                max_width = TIE_WIDTH;
            end else begin
                // Centrar "GANA JUGADOR X" (336 pixels de ancho)
                rel_x = $signed(x) - $signed(TEXT_CENTER_X) + $signed(11'd168);
                max_width = WINNER_WIDTH;
            end
            
            rel_y = $signed(y) - $signed(TEXT_CENTER_Y) + $signed(11'd12);
            
            // Verificar si estamos en el rango del texto
            if (rel_x >= 0 && rel_x < max_width && rel_y >= 0 && rel_y < CHAR_HEIGHT) begin
                // Determinar índice de carácter usando división
                char_index = rel_x / CHAR_WIDTH;
                
                // Verificar que el índice sea válido
                if ((is_tie && char_index < TIE_CHARS) || 
                    (!is_tie && char_index < WINNER_CHARS)) begin
                    
                    // Calcular posición dentro del carácter
                    x_in_char = rel_x - (char_index * CHAR_WIDTH);
                    
                    // Posición dentro del carácter (escalado)
                    char_col = x_in_char / SCALE;
                    char_row = rel_y / SCALE;
                    
                    // Obtener patrón del carácter según el mensaje
                    if (is_tie)
                        char_pattern = get_char_pattern_tie(char_index, char_row);
                    else
                        char_pattern = get_char_pattern_winner(char_index, char_row, winner_num);
                    
                    // Extraer pixel del patrón
                    text_pixel <= char_pattern[7 - char_col];
                end
            end
        end
    end
    
    // Función para "GANA JUGADOR X" (14 caracteres)
    function automatic logic [7:0] get_char_pattern_winner(
        input logic [3:0] char_idx, 
        input logic [2:0] row,
        input logic [3:0] player_num
    );
        case (char_idx)
            // G
            4'd0: case(row)
                3'd0: return 8'b01111110;
                3'd1: return 8'b11000000;
                3'd2: return 8'b11000000;
                3'd3: return 8'b11001110;
                3'd4: return 8'b11000110;
                3'd5: return 8'b11000110;
                3'd6: return 8'b01111110;
                3'd7: return 8'b00000000;
            endcase
            
            // A
            4'd1: case(row)
                3'd0: return 8'b00111100;
                3'd1: return 8'b01100110;
                3'd2: return 8'b11000011;
                3'd3: return 8'b11111111;
                3'd4: return 8'b11000011;
                3'd5: return 8'b11000011;
                3'd6: return 8'b11000011;
                3'd7: return 8'b00000000;
            endcase
            
            // N
            4'd2: case(row)
                3'd0: return 8'b11000011;
                3'd1: return 8'b11100011;
                3'd2: return 8'b11110011;
                3'd3: return 8'b11011011;
                3'd4: return 8'b11001111;
                3'd5: return 8'b11000111;
                3'd6: return 8'b11000011;
                3'd7: return 8'b00000000;
            endcase
            
            // A
            4'd3: case(row)
                3'd0: return 8'b00111100;
                3'd1: return 8'b01100110;
                3'd2: return 8'b11000011;
                3'd3: return 8'b11111111;
                3'd4: return 8'b11000011;
                3'd5: return 8'b11000011;
                3'd6: return 8'b11000011;
                3'd7: return 8'b00000000;
            endcase
            
            // (espacio)
            4'd4: return 8'b00000000;
            
            // J
            4'd5: case(row)
                3'd0: return 8'b00011111;
                3'd1: return 8'b00000110;
                3'd2: return 8'b00000110;
                3'd3: return 8'b00000110;
                3'd4: return 8'b11000110;
                3'd5: return 8'b11000110;
                3'd6: return 8'b01111100;
                3'd7: return 8'b00000000;
            endcase
            
            // U
            4'd6: case(row)
                3'd0: return 8'b11000011;
                3'd1: return 8'b11000011;
                3'd2: return 8'b11000011;
                3'd3: return 8'b11000011;
                3'd4: return 8'b11000011;
                3'd5: return 8'b11000011;
                3'd6: return 8'b01111110;
                3'd7: return 8'b00000000;
            endcase
            
            // G
            4'd7: case(row)
                3'd0: return 8'b01111110;
                3'd1: return 8'b11000000;
                3'd2: return 8'b11000000;
                3'd3: return 8'b11001110;
                3'd4: return 8'b11000110;
                3'd5: return 8'b11000110;
                3'd6: return 8'b01111110;
                3'd7: return 8'b00000000;
            endcase
            
            // A
            4'd8: case(row)
                3'd0: return 8'b00111100;
                3'd1: return 8'b01100110;
                3'd2: return 8'b11000011;
                3'd3: return 8'b11111111;
                3'd4: return 8'b11000011;
                3'd5: return 8'b11000011;
                3'd6: return 8'b11000011;
                3'd7: return 8'b00000000;
            endcase
            
            // D
            4'd9: case(row)
                3'd0: return 8'b11111100;
                3'd1: return 8'b11000110;
                3'd2: return 8'b11000011;
                3'd3: return 8'b11000011;
                3'd4: return 8'b11000011;
                3'd5: return 8'b11000110;
                3'd6: return 8'b11111100;
                3'd7: return 8'b00000000;
            endcase
            
            // O
            4'd10: case(row)
                3'd0: return 8'b01111110;
                3'd1: return 8'b11000011;
                3'd2: return 8'b11000011;
                3'd3: return 8'b11000011;
                3'd4: return 8'b11000011;
                3'd5: return 8'b11000011;
                3'd6: return 8'b01111110;
                3'd7: return 8'b00000000;
            endcase
            
            // R
            4'd11: case(row)
                3'd0: return 8'b11111100;
                3'd1: return 8'b11000110;
                3'd2: return 8'b11000110;
                3'd3: return 8'b11111100;
                3'd4: return 8'b11001100;
                3'd5: return 8'b11000110;
                3'd6: return 8'b11000011;
                3'd7: return 8'b00000000;
            endcase
            
            // (espacio)
            4'd12: return 8'b00000000;
            
            // Número (1 o 2)
            4'd13: begin
                if (player_num == 4'd1) begin
                    case(row)
                        3'd0: return 8'b00011000;
                        3'd1: return 8'b00111000;
                        3'd2: return 8'b00011000;
                        3'd3: return 8'b00011000;
                        3'd4: return 8'b00011000;
                        3'd5: return 8'b00011000;
                        3'd6: return 8'b01111110;
                        3'd7: return 8'b00000000;
                    endcase
                end else begin
                    case(row)
                        3'd0: return 8'b01111110;
                        3'd1: return 8'b11000011;
                        3'd2: return 8'b00000011;
                        3'd3: return 8'b00001110;
                        3'd4: return 8'b00111000;
                        3'd5: return 8'b11100000;
                        3'd6: return 8'b11111111;
                        3'd7: return 8'b00000000;
                    endcase
                end
            end
            
            default: return 8'b00000000;
        endcase
    endfunction
    
    // Función para "EMPATE" (6 caracteres)
    function automatic logic [7:0] get_char_pattern_tie(input logic [3:0] char_idx, input logic [2:0] row);
        case (char_idx)
            // E
            4'd0: case(row)
                3'd0: return 8'b11111111;
                3'd1: return 8'b11000000;
                3'd2: return 8'b11000000;
                3'd3: return 8'b11111110;
                3'd4: return 8'b11000000;
                3'd5: return 8'b11000000;
                3'd6: return 8'b11111111;
                3'd7: return 8'b00000000;
            endcase
            
            // M
            4'd1: case(row)
                3'd0: return 8'b11000011;
                3'd1: return 8'b11100111;
                3'd2: return 8'b11111111;
                3'd3: return 8'b11011011;
                3'd4: return 8'b11000011;
                3'd5: return 8'b11000011;
                3'd6: return 8'b11000011;
                3'd7: return 8'b00000000;
            endcase
            
            // P
            4'd2: case(row)
                3'd0: return 8'b11111110;
                3'd1: return 8'b11000011;
                3'd2: return 8'b11000011;
                3'd3: return 8'b11111110;
                3'd4: return 8'b11000000;
                3'd5: return 8'b11000000;
                3'd6: return 8'b11000000;
                3'd7: return 8'b00000000;
            endcase
            
            // A
            4'd3: case(row)
                3'd0: return 8'b00111100;
                3'd1: return 8'b01100110;
                3'd2: return 8'b11000011;
                3'd3: return 8'b11111111;
                3'd4: return 8'b11000011;
                3'd5: return 8'b11000011;
                3'd6: return 8'b11000011;
                3'd7: return 8'b00000000;
            endcase
            
            // T
            4'd4: case(row)
                3'd0: return 8'b11111111;
                3'd1: return 8'b00011000;
                3'd2: return 8'b00011000;
                3'd3: return 8'b00011000;
                3'd4: return 8'b00011000;
                3'd5: return 8'b00011000;
                3'd6: return 8'b00011000;
                3'd7: return 8'b00000000;
            endcase
            
            // E
            4'd5: case(row)
                3'd0: return 8'b11111111;
                3'd1: return 8'b11000000;
                3'd2: return 8'b11000000;
                3'd3: return 8'b11111110;
                3'd4: return 8'b11000000;
                3'd5: return 8'b11000000;
                3'd6: return 8'b11111111;
                3'd7: return 8'b00000000;
            endcase
            
            default: return 8'b00000000;
        endcase
    endfunction

endmodule
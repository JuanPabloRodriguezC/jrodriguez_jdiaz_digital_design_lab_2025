module fsm(
    // Inputs
    input  logic       clk,
    input  logic       rst,
    input  logic       carta_recibida,     
    input  logic       timer_timeout,
    input  logic [3:0] carta1_reg,
    input  logic [3:0] carta2_reg,
    input  logic [3:0] random_card1,
    input  logic [3:0] random_card2,
    
    // Outputs
    output logic        turno,
    output logic        selector_carta,
    output logic        timer_reset,
    output logic        timer_enable,
    output logic [3:0]  puntaje1_reg,
    output logic [3:0]  puntaje2_reg,
    output logic        sig_carta_aleatoria,
    output logic [15:0] cards_face_up
);    

    // --- STATE ENCODING ---
    typedef enum logic [2:0] {
        S0_WAIT_CARD1    = 3'b000,
        S1_WAIT_CARD2    = 3'b001,
        S2_CHECK_MATCH   = 3'b010,
        S3_PLAYER_SCORED = 3'b011,
        S4_RANDOM_SELECT = 3'b100,
        S5_SHOW_CARDS    = 3'b101,
        S6_GAME_OVER     = 3'b110
    } state_t;
    
    state_t state, next_state;
    
    // --- INTERNAL REGISTERS ---
    logic [4:0]  cartas_disponibles_reg;
    logic        cards_match;
    logic [15:0] cards_matched;        // Cartas ya encontradas (permanentemente volteadas)
    logic [25:0] delay_counter;
    logic [3:0]  carta1_pos, carta2_pos;  // Posiciones de las cartas seleccionadas
    
    // Tabla de valores de cartas (8 pares: 0,0,1,1,2,2...7,7)
    // Cada posición tiene un valor de símbolo
    logic [2:0] card_values [0:15];
    
    initial begin
        card_values[0]  = 3'd0;  card_values[1]  = 3'd0;
        card_values[2]  = 3'd1;  card_values[3]  = 3'd1;
        card_values[4]  = 3'd2;  card_values[5]  = 3'd2;
        card_values[6]  = 3'd3;  card_values[7]  = 3'd3;
        card_values[8]  = 3'd4;  card_values[9]  = 3'd4;
        card_values[10] = 3'd5;  card_values[11] = 3'd5;
        card_values[12] = 3'd6;  card_values[13] = 3'd6;
        card_values[14] = 3'd7;  card_values[15] = 3'd7;
    end
    
    localparam DELAY_CYCLES = 26'd50_000_000;  // 1 segundo @ 50MHz

    assign sig_carta_aleatoria = (state == S4_RANDOM_SELECT);
    
    // Comparar VALORES de las cartas, no sus posiciones
    assign cards_match = (card_values[carta1_pos] == card_values[carta2_pos]) && 
                        (carta1_pos != carta2_pos);  // No puede ser la misma carta

    // --- DISPLAY LOGIC ---
    always_comb begin
        cards_face_up = cards_matched;  // Base: solo cartas ya encontradas

        case (state)
            S1_WAIT_CARD2: cards_face_up[carta1_pos] = 1'b1;
            S2_CHECK_MATCH,
            S3_PLAYER_SCORED,
            S5_SHOW_CARDS: begin
                cards_face_up[carta1_pos] = 1'b1;
                cards_face_up[carta2_pos] = 1'b1;
            end
            default: ;
        endcase
    end

    // --- STATE REGISTER + DELAY COUNTER ---
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S0_WAIT_CARD1;
            delay_counter <= 26'd0;
        end else begin
            state <= next_state;

            if (state == S5_SHOW_CARDS) begin
                if (delay_counter < DELAY_CYCLES)
                    delay_counter <= delay_counter + 1;
            end else begin
                delay_counter <= 26'd0;
            end
        end
    end

    // --- NEXT STATE LOGIC ---
    always_comb begin
        next_state = state;

        case (state)
            S0_WAIT_CARD1: begin
                if (timer_timeout)
                    next_state = S4_RANDOM_SELECT;
                else if (carta_recibida)
                    next_state = S1_WAIT_CARD2;
            end
            
            S1_WAIT_CARD2: begin
                if (timer_timeout)
                    next_state = S4_RANDOM_SELECT;
                else if (carta_recibida)
                    next_state = S2_CHECK_MATCH;
            end
            
            S2_CHECK_MATCH: begin
                next_state = S5_SHOW_CARDS;
            end
            
            S5_SHOW_CARDS: begin
                if (delay_counter >= DELAY_CYCLES) begin
                    if (cards_match)
                        next_state = S3_PLAYER_SCORED;
                    else
                        next_state = S0_WAIT_CARD1;
                end
            end
            
            S3_PLAYER_SCORED: begin
                if (cartas_disponibles_reg <= 2)
                    next_state = S6_GAME_OVER;
                else
                    next_state = S0_WAIT_CARD1;
            end
            
            S4_RANDOM_SELECT: begin
                next_state = S2_CHECK_MATCH;
            end
            
            S6_GAME_OVER: next_state = S6_GAME_OVER;

            default: next_state = S0_WAIT_CARD1;
        endcase
    end

    // --- OUTPUT & SCORE LOGIC ---
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            puntaje1_reg <= 4'h0;
            puntaje2_reg <= 4'h0;
            turno <= 1'b0;
            cartas_disponibles_reg <= 5'd16;
            selector_carta <= 1'b0;
            cards_matched <= 16'h0000;
            carta1_pos <= 4'h0;
            carta2_pos <= 4'h0;
        end else begin
            case (state)
                S0_WAIT_CARD1: begin
                    selector_carta <= 1'b0;
                    // Capturar carta1 del usuario
                    if (carta_recibida && !cards_matched[carta1_reg])
                        carta1_pos <= carta1_reg;
                end
                
                S1_WAIT_CARD2: begin
                    selector_carta <= 1'b1;
                    // Capturar carta2 del usuario
                    if (carta_recibida && !cards_matched[carta2_reg] && carta2_reg != carta1_pos)
                        carta2_pos <= carta2_reg;
                end
                
                S4_RANDOM_SELECT: begin
                    // Selección aleatoria por timeout
                    if (selector_carta == 1'b0) begin
                        // Timeout en espera de carta1 - seleccionar ambas
                        carta1_pos <= random_card1;
                        carta2_pos <= random_card2;
                    end else begin
                        // Timeout en espera de carta2 - solo seleccionar carta2
                        // carta1_pos ya está seleccionada
                        carta2_pos <= random_card1;
                    end
                end
                
                S5_SHOW_CARDS: begin
                    // Cambiar turno solo si no hay match
                    if (delay_counter >= DELAY_CYCLES && !cards_match)
                        turno <= ~turno;
                end
                
                S3_PLAYER_SCORED: begin
                    if (turno == 1'b0)
                        puntaje1_reg <= puntaje1_reg + 4'h1;
                    else
                        puntaje2_reg <= puntaje2_reg + 4'h1;

                    cartas_disponibles_reg <= cartas_disponibles_reg - 5'd2;
                    
                    // Marcar las cartas como encontradas (permanentemente volteadas)
                    cards_matched[carta1_pos] <= 1'b1;
                    cards_matched[carta2_pos] <= 1'b1;
                end
                
                default: ;
            endcase
        end
    end

    // --- TIMER CONTROL ---
    always_comb begin
        timer_enable = 1'b0;
        timer_reset  = 1'b1;

        case (state)
            S0_WAIT_CARD1,
            S1_WAIT_CARD2: begin
                timer_enable = 1'b1;
                timer_reset  = 1'b0;
            end
            default: begin
                timer_enable = 1'b0;
                timer_reset  = 1'b1;
            end
        endcase
    end

endmodule
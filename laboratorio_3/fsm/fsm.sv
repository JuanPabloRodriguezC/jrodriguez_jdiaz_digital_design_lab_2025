module fsm(
    // Inputs
    input  logic       clk,
    input  logic       rst,
    input  logic       carta_recibida,     
    input  logic       timer_timeout,
    input  logic [3:0] carta1_reg,
    input  logic [3:0] carta2_reg,
    input  logic [3:0] random_card1,      // Carta aleatoria 1
    input  logic [3:0] random_card2,      // Carta aleatoria 2
    
    // Outputs
    output logic        turno,
    output logic        selector_carta,
    output logic        timer_reset,
    output logic        timer_enable,
    output logic [3:0]  puntaje1_reg,
    output logic [3:0]  puntaje2_reg,
    output logic        sig_carta_aleatoria,
    output logic [15:0] cards_face_up  // Bit en 1 = carta volteada
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
    logic [15:0] cards_matched;  // Cartas ya encontradas (permanentemente volteadas)
    logic [25:0] delay_counter;
    logic [3:0]  carta1_actual, carta2_actual;  // Cartas actualmente siendo evaluadas
    localparam DELAY_CYCLES = 26'd50_000_000;  // 1 segundo @ 50MHz

    assign sig_carta_aleatoria = (state == S4_RANDOM_SELECT);
    assign cards_match = (carta1_actual == carta2_actual);

    // --- DISPLAY LOGIC ---
    // Las cartas están boca abajo por defecto (cards_face_up = 0)
    // Solo se muestran: las ya encontradas (cards_matched) y las temporalmente seleccionadas
    always_comb begin
        cards_face_up = cards_matched;  // Base: solo cartas ya encontradas

        case (state)
            S1_WAIT_CARD2: cards_face_up[carta1_actual] = 1'b1;
            S2_CHECK_MATCH,
            S3_PLAYER_SCORED,
            S4_RANDOM_SELECT,
            S5_SHOW_CARDS: begin
                cards_face_up[carta1_actual] = 1'b1;
                cards_face_up[carta2_actual] = 1'b1;
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
            carta1_actual <= 4'h0;
            carta2_actual <= 4'h0;
        end else begin
            case (state)
                S0_WAIT_CARD1: begin
                    selector_carta <= 1'b0;
                    // Capturar carta1 (del usuario o aleatoria)
                    if (carta_recibida)
                        carta1_actual <= carta1_reg;
                end
                
                S1_WAIT_CARD2: begin
                    selector_carta <= 1'b1;
                    // Capturar carta2 (del usuario o aleatoria)
                    if (carta_recibida)
                        carta2_actual <= carta2_reg;
                end
                
                S4_RANDOM_SELECT: begin
                    // Selección aleatoria por timeout
                    if (selector_carta == 1'b0) begin
                        // Timeout en espera de carta1
                        carta1_actual <= random_card1;
                        carta2_actual <= random_card2;
                    end else begin
                        // Timeout en espera de carta2 (carta1 ya está seleccionada)
                        carta2_actual <= random_card1;
                    end
                end
                
                S5_SHOW_CARDS: begin
                    if (delay_counter >= DELAY_CYCLES && !cards_match)
                        turno <= ~turno;
                end
                
                S3_PLAYER_SCORED: begin
                    if (turno == 1'b0)
                        puntaje1_reg <= puntaje1_reg + 4'h1;
                    else
                        puntaje2_reg <= puntaje2_reg + 4'h1;

                    cartas_disponibles_reg <= cartas_disponibles_reg - 5'd2;
                    cards_matched[carta1_actual] <= 1'b1;
                    cards_matched[carta2_actual] <= 1'b1;
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
module fsm(
    // Inputs (status del sistema)
    input  logic       clk,
    input  logic       rst,
    input  logic       carta_recibida,
    input  logic       timer_timeout,
    input  logic       cards_match,
    input  logic       game_over,
    input  logic [3:0] carta1_pos,
    input  logic [3:0] carta2_pos,
    
    // Outputs (SOLO señales de control)
    output logic        enable_score1,
    output logic        enable_score2,
    output logic        load_carta1,
    output logic        load_carta2,
    output logic        mark_match,
    output logic        selector_carta,
    output logic        timer_reset,
    output logic        timer_enable,
    output logic        use_random,
    output logic        turno,
    output logic [15:0] cards_face_up
);

    typedef enum logic [2:0] {
        S0_WAIT_CARD1    = 3'b000,
        S1_WAIT_CARD2    = 3'b001,
        S2_CHECK_MATCH   = 3'b010,
        S3_PLAYER_SCORED = 3'b011,
        S4_RANDOM_SELECT = 3'b100,
        S5_SHOW_CARDS    = 3'b101,
        S6_GAME_OVER     = 3'b110
    } state_t;
    
    (* syn_encoding = "user" *) state_t state, next_state;
    
    logic [25:0] delay_counter;
    logic delay_done;
    logic turno_reg;
    
    localparam DELAY_CYCLES = 26'd50_000_000;
    
    assign delay_done = (delay_counter >= DELAY_CYCLES);
    assign turno = turno_reg;

    // ===== Registro de estado =====
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= S0_WAIT_CARD1;
        else
            state <= next_state;
    end

    // ===== Contador de delay =====
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            delay_counter <= 26'd0;
        end else begin
            if (state == S5_SHOW_CARDS && delay_counter < DELAY_CYCLES)
                delay_counter <= delay_counter + 1;
            else if (state != S5_SHOW_CARDS)
                delay_counter <= 26'd0;
        end
    end

    // ===== Registro de turno =====
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            turno_reg <= 1'b0;
        end else begin
            // Solo cambiar turno al finalizar S5_SHOW_CARDS y sin match
            if (state == S5_SHOW_CARDS && next_state == S0_WAIT_CARD1 && !cards_match)
                turno_reg <= ~turno_reg;
        end
    end

    // ===== Lógica de próximo estado =====
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
                if (delay_done) begin
                    if (cards_match)
                        next_state = S3_PLAYER_SCORED;
                    else
                        next_state = S0_WAIT_CARD1;
                end
            end
            
            S3_PLAYER_SCORED: begin
                if (game_over)
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

    // ===== Señales de control (combinacionales) =====
    always_comb begin
        // Defaults
        enable_score1 = 1'b0;
        enable_score2 = 1'b0;
        load_carta1 = 1'b0;
        load_carta2 = 1'b0;
        mark_match = 1'b0;
        selector_carta = 1'b0;
        timer_reset = 1'b1;
        timer_enable = 1'b0;
        use_random = 1'b0;
        cards_face_up = 16'h0000;

        case (state)
            S0_WAIT_CARD1: begin
                selector_carta = 1'b0;
                timer_reset = 1'b0;
                timer_enable = 1'b1;
                load_carta1 = carta_recibida;
            end
            
            S1_WAIT_CARD2: begin
                selector_carta = 1'b1;
                timer_reset = 1'b0;
                timer_enable = 1'b1;
                cards_face_up[carta1_pos] = 1'b1;
                load_carta2 = carta_recibida;
            end
            
            S4_RANDOM_SELECT: begin
                use_random = 1'b1;
            end
            
            S2_CHECK_MATCH,
            S5_SHOW_CARDS: begin
                cards_face_up[carta1_pos] = 1'b1;
                cards_face_up[carta2_pos] = 1'b1;
            end
            
            S3_PLAYER_SCORED: begin
                mark_match = 1'b1;
                cards_face_up[carta1_pos] = 1'b1;
                cards_face_up[carta2_pos] = 1'b1;
                
                if (turno_reg == 1'b0)
                    enable_score1 = 1'b1;
                else
                    enable_score2 = 1'b1;
            end
            
            S6_GAME_OVER: begin
                // Mostrar todas las cartas encontradas
                // (esto lo maneja cardTracker)
            end
            
            default: ;
        endcase
    end

endmodule
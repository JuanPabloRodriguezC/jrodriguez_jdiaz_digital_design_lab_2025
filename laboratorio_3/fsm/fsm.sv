module fsm(
    input  logic       clk,
    input  logic       rst,
    input  logic       carta_recibida,
    input  logic       timer_timeout,
    input  logic       cards_match,
    input  logic       game_over,
    input  logic [3:0] carta1_pos,
    input  logic [3:0] carta2_pos,
    input  logic       random_ready,
    
    output logic        enable_score,
    output logic        mark_match,
    output logic [1:0]  selector_carta,
    output logic        timer_reset,
    output logic        timer_enable,
    output logic        request_random,
    output logic        use_random,
    output logic        turno,
    output logic [15:0] cards_face_up
);

    typedef enum logic [2:0] {
        S0_SHOW_CARDS    = 3'b000,
        S1_WAIT_CARD1    = 3'b001,
        S2_WAIT_CARD2    = 3'b010,
        S3_CHECK_MATCH   = 3'b011,
        S4_PLAYER_SCORED = 3'b100,
        S5_RANDOM_SELECT = 3'b101,
        S6_GAME_OVER     = 3'b110,
        S7_SHOW_MISMATCH = 3'b111
    } state_t;
    
    (* syn_encoding = "one-hot" *) state_t state, next_state;
    
    logic [25:0] delay_counter;
    logic delay_done;
    logic turno_reg;
    
    localparam DELAY_SHOW_CARDS = 26'd150_000_000;  // 3 seconds
    localparam DELAY_MISMATCH = 26'd50_000_000;     // 1 second
    
    assign turno = turno_reg;

    // ===== Estado y contador =====
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S0_SHOW_CARDS;
            delay_counter <= 26'd0;
        end else begin
            state <= next_state;
            
            // Contador de delay
            if (state == S0_SHOW_CARDS && delay_counter < DELAY_SHOW_CARDS)
                delay_counter <= delay_counter + 1;
            else if (state == S7_SHOW_MISMATCH && delay_counter < DELAY_MISMATCH)
                delay_counter <= delay_counter + 1;
            else
                delay_counter <= 26'd0;
        end
    end
    
    // Determinar si el delay terminó
    always_comb begin
        if (state == S0_SHOW_CARDS)
            delay_done = (delay_counter >= DELAY_SHOW_CARDS);
        else if (state == S7_SHOW_MISMATCH)
            delay_done = (delay_counter >= DELAY_MISMATCH);
        else
            delay_done = 1'b0;
    end

    // ===== Registro de turno =====
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            turno_reg <= 1'b0;
        end else begin
            // Cambiar turno al salir de SHOW_MISMATCH
            if (state == S7_SHOW_MISMATCH && next_state == S1_WAIT_CARD1)
                turno_reg <= ~turno_reg;
        end
    end

    // ===== Lógica de próximo estado =====
    always_comb begin
        next_state = state;

        case (state)
            S0_SHOW_CARDS: begin
                if (delay_done)
                    next_state = S1_WAIT_CARD1;
            end

            S1_WAIT_CARD1: begin
                if (timer_timeout)
                    next_state = S5_RANDOM_SELECT;
                else if (carta_recibida)
                    next_state = S2_WAIT_CARD2;
            end
            
            S2_WAIT_CARD2: begin
                if (timer_timeout)
                    next_state = S5_RANDOM_SELECT;
                else if (carta_recibida)
                    next_state = S3_CHECK_MATCH;
            end
            
            S3_CHECK_MATCH: begin
                if (cards_match)
                    next_state = S4_PLAYER_SCORED;
                else
                    next_state = S7_SHOW_MISMATCH;
            end
            
            S4_PLAYER_SCORED: begin
                if (game_over)
                    next_state = S6_GAME_OVER;
                else
                    next_state = S1_WAIT_CARD1;
            end
            
            S5_RANDOM_SELECT: begin
                if (random_ready)
                    next_state = S3_CHECK_MATCH;
            end
            
            S7_SHOW_MISMATCH: begin
                if (delay_done)
                    next_state = S1_WAIT_CARD1;
            end
     
            S6_GAME_OVER: begin
                next_state = S6_GAME_OVER;
            end

            default: next_state = S1_WAIT_CARD1;
        endcase
    end

    // ===== Señales de control =====
    always_comb begin
        // Defaults
        enable_score = 1'b0;
        mark_match = 1'b0;
        selector_carta = 2'b00;
        timer_reset = 1'b1;
        timer_enable = 1'b0;
        use_random = 1'b0;
        cards_face_up = 16'h0000;

        case (state)
            S0_SHOW_CARDS: begin
                cards_face_up = 16'hFFFF;  // Show all cards
                selector_carta = 2'b00;
            end

            S1_WAIT_CARD1: begin
                selector_carta = 2'b01;
                timer_reset = 1'b0;
                timer_enable = 1'b1;
            end
            
            S2_WAIT_CARD2: begin
                selector_carta = 2'b10;
                timer_reset = 1'b0;
                timer_enable = 1'b1;
                cards_face_up[carta1_pos] = 1'b1;  // Show first card only
            end
            
            S3_CHECK_MATCH: begin
                cards_face_up[carta1_pos] = 1'b1;
                cards_face_up[carta2_pos] = 1'b1;
            end

            S4_PLAYER_SCORED: begin
                mark_match = 1'b1;
                enable_score = 1'b1;
                cards_face_up[carta1_pos] = 1'b1;
                cards_face_up[carta2_pos] = 1'b1;
            end

            S5_RANDOM_SELECT: begin
                request_random = 1'b1;
                if (random_ready)
                    use_random = 1'b1;

            end
            
            S7_SHOW_MISMATCH: begin
                // Show mismatched cards briefly
                cards_face_up[carta1_pos] = 1'b1;
                cards_face_up[carta2_pos] = 1'b1;
            end
            
            S6_GAME_OVER: begin
                // Could show all matched cards
            end
            
            default: ;
        endcase
    end

endmodule
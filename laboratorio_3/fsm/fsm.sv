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
    

    output logic        enable_score1,
    output logic        enable_score2,
    output logic        load_carta1,
    output logic        load_carta2,
    output logic        mark_match,
    output logic [1:0]  selector_carta,
    output logic        timer_reset,
    output logic        timer_enable,
    output logic        request_random,
    output logic        use_random,
    output logic        turno,
    output logic [15:0] cards_face_up
);

// definicion de estados
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
	 
	 
	 // logica secuencial para asignar estados
    

    (* syn_encoding = "sequential" *) state_t state;
    state_t next_state;
    
    logic [25:0] delay_counter; // para que las cartas se esperen al ser mostradas
    logic delay_done; // cuando termina el delay
    logic turno_reg; // registro del turno
    
    localparam DELAY_SHOW_CARDS = 26'd150_000_000;  // 3 seconds
    localparam DELAY_MISMATCH = 26'd50_000_000;     // 1 second
    
    assign turno = turno_reg;


    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= S0_WAIT_CARD1;
        else
            state <= next_state;
    end
	 
	 // asigna delay durante el S5 Show cards


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

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            turno_reg <= 1'b0;
        end else begin

            if (state == S5_SHOW_CARDS && next_state == S0_WAIT_CARD1 && !cards_match)

                turno_reg <= ~turno_reg;
        end
    end
	 
	 // next state logic

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

                    next_state = S1_WAIT_CARD2;
						  else next_state = S0_WAIT_CARD1;

            end
            
            S2_WAIT_CARD2: begin
                if (timer_timeout)
                    next_state = S5_RANDOM_SELECT;
                else if (carta_recibida)

                    next_state = S2_CHECK_MATCH;
						  else next_state = S1_WAIT_CARD2;
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
					 end else begin
						  next_state = S5_SHOW_CARDS;
					 end
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
	 
	 // assign señales - logica de salida


    always_comb begin
        enable_score1 = 1'b0;
        enable_score2 = 1'b0;
        load_carta1 = 1'b0;
        load_carta2 = 1'b0;

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
            

            S4_RANDOM_SELECT: begin
                use_random = 1'b1;

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
				
						timer_reset = 1'b0;
						timer_enable = 1'b0;
				
            end
            
            default: ;
        endcase
    end

endmodule
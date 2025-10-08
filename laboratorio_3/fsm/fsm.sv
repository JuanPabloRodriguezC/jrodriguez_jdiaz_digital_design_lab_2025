module fsm(
    // Inputs
    input  logic       clk,
    input  logic       rst,
    input  logic       carta_recibida,     
    input  logic       timer_timeout,
    input  logic [3:0] carta1_reg,
    input  logic [3:0] carta2_reg,
    
    // Outputs
    output logic       turno,
    output logic       selector_carta,
    output logic       timer_reset,
    output logic       timer_enable,
    output logic [3:0] puntaje1_reg,
    output logic [3:0] puntaje2_reg,
    output logic       sig_carta_aleatoria
);    

    // State encoding
    typedef enum logic [2:0] {
        S0_WAIT_CARD1    = 3'b000,
        S1_WAIT_CARD2    = 3'b001,
        S2_CHECK_MATCH   = 3'b010,
        S3_PLAYER_SCORED = 3'b011,
        S4_RANDOM_SELECT = 3'b100,
        S5_GAME_OVER     = 3'b101
    } state_t;
    
    state_t state, next_state;
    
    // Internal registers
    logic [4:0] cartas_disponibles_reg;
    logic       cards_match;

    assign sig_carta_aleatoria = (state == S4_RANDOM_SELECT);
    
    // Check if cards match
    assign cards_match = (carta1_reg == carta2_reg);

    // State register
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= S0_WAIT_CARD1;
        else
            state <= next_state;
    end
    
    // Next state logic
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
                if (cards_match)
                    next_state = S3_PLAYER_SCORED;
                else
                    next_state = S0_WAIT_CARD1;  // No match, change turn
            end
            
            S3_PLAYER_SCORED: begin
                if (cartas_disponibles_reg <= 2)  // Si quedan 2 o menos cartas
                    next_state = S5_GAME_OVER;
                else
                    next_state = S0_WAIT_CARD1;  // Same player continues
            end
            
            S4_RANDOM_SELECT: begin
                next_state = S2_CHECK_MATCH;  // Check random cards
            end
            
            S5_GAME_OVER: begin
                next_state = S5_GAME_OVER;  // Stay in game over
            end
            
            default: next_state = S0_WAIT_CARD1;
        endcase
    end
    
    // Output and register logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            puntaje1_reg <= 4'h0;
            puntaje2_reg <= 4'h0;
            turno <= 1'b0;
            cartas_disponibles_reg <= 5'd16;
            selector_carta <= 1'b0;
        end
        else begin
            case (state)
                S0_WAIT_CARD1: begin
                    selector_carta <= 1'b0;
                end
                
                S1_WAIT_CARD2: begin
                    selector_carta <= 1'b1;
                end
                
                S2_CHECK_MATCH: begin
                    if (!cards_match) begin
                        turno <= ~turno;
                    end
                end
                
                S3_PLAYER_SCORED: begin
                    if (turno == 1'b0)
                        puntaje1_reg <= puntaje1_reg + 4'h1;
                    else
                        puntaje2_reg <= puntaje2_reg + 4'h1;
                    
                    cartas_disponibles_reg <= cartas_disponibles_reg - 5'd2;
                end
                
                default: ;
            endcase
        end
    end
    
    // Timer control logic
    always_comb begin
        timer_enable = 1'b0;
        timer_reset = 1'b0;
        
        case (state)
            S0_WAIT_CARD1: begin
                timer_enable = 1'b1; // Timer runs while waiting
                timer_reset = 1'b0;
            end
            
            S1_WAIT_CARD2: begin
                timer_enable = 1'b1;
                timer_reset = 1'b0;
            end
            
            S2_CHECK_MATCH: begin
                timer_enable = 1'b0;
                timer_reset = 1'b1;  // Reset timer after checking
            end
            
            S3_PLAYER_SCORED: begin
                timer_enable = 1'b0;
                timer_reset = 1'b1;
            end
            
            S4_RANDOM_SELECT: begin
                timer_enable = 1'b0;
                timer_reset = 1'b1;
            end
            
            S5_GAME_OVER: begin
                timer_enable = 1'b0;
                timer_reset = 1'b0;
            end
            
            default: begin
                timer_enable = 1'b0;
                timer_reset = 1'b0;
            end
        endcase
    end

endmodule
// Code your design here
module FSM(
    // Inputs
    input  logic       clk,
    input  logic       rst,
    input  logic       carta_recibida,
    input  logic [3:0] card_id,       
    input  logic       timer_timeout,
    input  logic [3:0] random_card1,
    input  logic [3:0] random_card2,
    
    // Outputs
    output logic [3:0] carta1,
    output logic [3:0] carta2,
    output logic [3:0] puntaje1,
    output logic [3:0] puntaje2,
    output logic       turno,
    output logic [4:0] num_cartas_disponibles,
    output logic       timer_reset,
    output logic       timer_enable,
    output logic [2:0] state_out            // Current state (for debugging)
);    
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
    logic [3:0] carta1_reg, carta2_reg;
    logic [3:0] puntaje1_reg, puntaje2_reg;
    logic       turno_reg;
    logic [4:0] cartas_disponibles_reg;
    logic       cards_match;
    
    assign cards_match = (carta1_reg == carta2_reg);
    

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= S0_WAIT_CARD1;
        else
            state <= next_state;
    end
    
    always_comb begin
        // Default: stay in current state
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
                if (cartas_disponibles_reg == 0)
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
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            carta1_reg <= 0;
            carta2_reg <= 0;
            puntaje1_reg <= 0;
            puntaje2_reg <= 0;
            turno_reg <= 0;
            cartas_disponibles_reg <= 16;
        end
        else begin
            case (state)
                S0_WAIT_CARD1: begin
                    if (carta_recibida) begin
                        carta1_reg <= card_id;  // Store first card
                    end
                end
                
                S1_WAIT_CARD2: begin
                    if (carta_recibida) begin
                        carta2_reg <= card_id;  // Store second card
                    end
                end
                
                S2_CHECK_MATCH: begin
                    if (!cards_match) begin
                        // No match: change turn for next state
                        turno_reg <= ~turno_reg;
                    end
                    // If match, turno stays same (handled in S3)
                end
                
                S3_PLAYER_SCORED: begin
                    // Increment current player's score
                    if (turno_reg == 0)
                        puntaje1_reg <= puntaje1_reg + 1;
                    else
                        puntaje2_reg <= puntaje2_reg + 1;
                    
                    // Reduce available cards
                    cartas_disponibles_reg <= cartas_disponibles_reg - 2;
                    
                    // turno_reg stays same (same player continues)
                end
                
                S4_RANDOM_SELECT: begin
                    // Store random cards
                    carta1_reg <= random_card1;
                    carta2_reg <= random_card2;
                end
                
                S5_GAME_OVER: begin
                    // Nothing to update, game is over
                end
            endcase
        end
    end
    
    always_comb begin
        timer_enable = 0;
        timer_reset = 0;
        
        case (state)
            S0_WAIT_CARD1: begin
                timer_enable = 1;  // Timer runs while waiting
                timer_reset = 0;
            end
            
            S1_WAIT_CARD2: begin
                timer_enable = 1;
                timer_reset = 0;
            end
            
            S2_CHECK_MATCH: begin
                timer_enable = 0;
                if (!cards_match)
                    timer_reset = 1;
            end
            
            S3_PLAYER_SCORED: begin
                timer_enable = 0;
                timer_reset = 1;
            end
            
            S4_RANDOM_SELECT: begin
                timer_enable = 0;
                timer_reset = 1;
            end
            
            S5_GAME_OVER: begin
                timer_enable = 0;
                timer_reset = 0;
            end
        endcase
    end
    
    assign carta1 = carta1_reg;
    assign carta2 = carta2_reg;
    assign puntaje1 = puntaje1_reg;
    assign puntaje2 = puntaje2_reg;
    assign turno = turno_reg;
    assign num_cartas_disponibles = cartas_disponibles_reg;
    assign state_out = state;

endmodule
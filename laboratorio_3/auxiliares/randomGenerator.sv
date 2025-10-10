module randomGenerator(
    input  logic       clk,
    input  logic       rst,
    input  logic       request_random,  // Pulse from FSM when random cards needed
    input  logic [15:0] cards_matched,
    output logic [3:0] random_card1,
    output logic [3:0] random_card2,
    output logic       random_ready     // Goes high when cards are valid
);
    // LFSR registers
    logic [15:0] lfsr1, lfsr2;
    logic feedback1, feedback2;
    
    // LFSR feedback polynomials
    assign feedback1 = lfsr1[15] ^ lfsr1[14] ^ lfsr1[12] ^ lfsr1[3];
    assign feedback2 = lfsr2[15] ^ lfsr2[13] ^ lfsr2[11] ^ lfsr2[1];
    
    // LFSR runs continuously for better randomness
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr1 <= 16'hACE1;
            lfsr2 <= 16'h5EED;
        end else begin
            lfsr1 <= {lfsr1[14:0], feedback1};
            lfsr2 <= {lfsr2[14:0], feedback2};
        end
    end
    
    // State machine for sequential card selection
    typedef enum logic [1:0] {
        IDLE        = 2'b00,
        FIND_CARD1  = 2'b01,
        FIND_CARD2  = 2'b10,
        DONE        = 2'b11
    } state_t;
    
    state_t state, next_state;
    
    // Working registers
    logic [3:0] candidate;
    logic [3:0] attempts;
    logic [3:0] card1_found;
    
    // State register
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    // Next state logic
    always_comb begin
        next_state = state;
        
        case (state)
            IDLE: begin
                if (request_random)
                    next_state = FIND_CARD1;
            end
            
            FIND_CARD1: begin
                // Found valid card1 OR exhausted attempts
                if (!cards_matched[candidate] || attempts >= 4'd15)
                    next_state = FIND_CARD2;
            end
            
            FIND_CARD2: begin
                // Found valid card2 OR exhausted attempts
                if ((!cards_matched[candidate] && candidate != card1_found) || attempts >= 4'd15)
                    next_state = DONE;
            end
            
            DONE: begin
                next_state = IDLE;
            end
        endcase
    end
    
    // Datapath
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            random_card1 <= 4'h0;
            random_card2 <= 4'h1;
            random_ready <= 1'b0;
            candidate <= 4'h0;
            attempts <= 4'h0;
            card1_found <= 4'h0;
        end else begin
            case (state)
                IDLE: begin
                    random_ready <= 1'b0;
                    if (request_random) begin
                        // Start search from current LFSR value
                        candidate <= lfsr1[3:0];
                        attempts <= 4'h0;
                    end
                end
                
                FIND_CARD1: begin
                    if (!cards_matched[candidate] || attempts >= 4'd15) begin
                        // Found valid card or gave up
                        random_card1 <= candidate;
                        card1_found <= candidate;  // Save for card2 comparison
                        candidate <= lfsr2[7:4];   // Start card2 search from different LFSR bits
                        attempts <= 4'h0;
                    end else begin
                        // Keep searching
                        candidate <= candidate + 4'd1;
                        attempts <= attempts + 4'd1;
                    end
                end
                
                FIND_CARD2: begin
                    if ((!cards_matched[candidate] && candidate != card1_found) || attempts >= 4'd15) begin
                        // Found valid card2 or gave up
                        random_card2 <= candidate;
                    end else begin
                        // Keep searching
                        candidate <= candidate + 4'd1;
                        attempts <= attempts + 4'd1;
                    end
                end
                
                DONE: begin
                    random_ready <= 1'b1;  // Signal that cards are ready
                end
            endcase
        end
    end
endmodule
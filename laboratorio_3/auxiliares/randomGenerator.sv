module randomGenerator(
    input  logic       clk,
    input  logic       rst,
    input  logic       request_random,  // Pulse when FSM needs random cards
    input  logic [15:0] cards_matched,
    output logic [3:0] random_card1,
    output logic [3:0] random_card2,
    output logic       random_ready     // Indicates cards are valid
);
    logic [15:0] lfsr1, lfsr2;
    logic feedback1, feedback2;
    
    assign feedback1 = lfsr1[15] ^ lfsr1[14] ^ lfsr1[12] ^ lfsr1[3];
    assign feedback2 = lfsr2[15] ^ lfsr2[13] ^ lfsr2[11] ^ lfsr2[1];
    
    // LFSR runs continuously
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr1 <= 16'hACE1;
            lfsr2 <= 16'h5EED;
        end else begin
            lfsr1 <= {lfsr1[14:0], feedback1};
            lfsr2 <= {lfsr2[14:0], feedback2};
        end
    end
    
    // Sequential card selection
    typedef enum logic [1:0] {
        IDLE,
        FIND_CARD1,
        FIND_CARD2,
        DONE
    } state_t;
    
    state_t state;
    logic [3:0] candidate;
    logic [3:0] attempts;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            random_card1 <= 4'h0;
            random_card2 <= 4'h1;
            random_ready <= 1'b0;
            candidate <= 4'h0;
            attempts <= 4'h0;
        end else begin
            case (state)
                IDLE: begin
                    random_ready <= 1'b0;
                    if (request_random) begin
                        candidate <= lfsr1[3:0];
                        attempts <= 4'h0;
                        state <= FIND_CARD1;
                    end
                end
                
                FIND_CARD1: begin
                    if (!cards_matched[candidate] || attempts >= 4'd15) begin
                        random_card1 <= candidate;
                        candidate <= lfsr2[7:4];
                        attempts <= 4'h0;
                        state <= FIND_CARD2;
                    end else begin
                        candidate <= candidate + 4'd1;
                        attempts <= attempts + 4'd1;
                    end
                end
                
                FIND_CARD2: begin
                    if ((!cards_matched[candidate] && candidate != random_card1) || attempts >= 4'd15) begin
                        random_card2 <= candidate;
                        state <= DONE;
                    end else begin
                        candidate <= candidate + 4'd1;
                        attempts <= attempts + 4'd1;
                    end
                end
                
                DONE: begin
                    random_ready <= 1'b1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
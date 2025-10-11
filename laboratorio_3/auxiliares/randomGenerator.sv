module randomGenerator( // dos generadores pseudoaleatorios basados en LFSR (Linear Feedback Shift Register)
    input  logic       clk,
    input  logic       rst,
    input  logic       request_random,  // Pulse from FSM when random cards needed
    input  logic [15:0] cards_matched,
    output logic [3:0] random_card1,
    output logic [3:0] random_card2,
    output logic       random_ready     // Goes high when cards are valid
);

    logic [15:0] lfsr1, lfsr2; // reg 16 bits para generar la secuencia

    logic feedback1, feedback2;
    
    assign feedback1 = lfsr1[15] ^ lfsr1[14] ^ lfsr1[12] ^ lfsr1[3]; // realiza XORs para formar un nuevo bit

    assign feedback2 = lfsr2[15] ^ lfsr2[13] ^ lfsr2[11] ^ lfsr2[1];
	 
	 // en cada pulso de reloj se actualizan los polinomios 
    
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
        

        while (attempts < 16 && cards_matched[temp1]) begin // toma como base el lsfr de 4 bits
		  // si ya fue emparejada, intenta con la siguiente
            temp1 = (temp1 + 4'd1) & 4'hF;
            attempts = attempts + 1;
        end
        
        random_card1 = temp1;
    end
    
    // Validar y ajustar random_card2
    always_comb begin
        automatic logic [3:0] temp2;
        automatic int attempts;
        
        temp2 = lfsr2_raw;
        attempts = 0;
        
        while (attempts < 16 && (cards_matched[temp2] || temp2 == random_card1)) begin
            temp2 = (temp2 + 4'd1) & 4'hF;
            attempts = attempts + 1;
        end
    end
endmodule
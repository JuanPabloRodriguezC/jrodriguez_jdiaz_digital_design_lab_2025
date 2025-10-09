module randomGenerator(
    input  logic       clk,
    input  logic       rst,
    input  logic [15:0] cards_matched,
    output logic [3:0] random_card1,
    output logic [3:0] random_card2
);
    logic [15:0] lfsr1, lfsr2;
    logic feedback1, feedback2;
    logic [3:0] lfsr1_raw, lfsr2_raw;
    
    assign feedback1 = lfsr1[15] ^ lfsr1[14] ^ lfsr1[12] ^ lfsr1[3];
    assign feedback2 = lfsr2[15] ^ lfsr2[13] ^ lfsr2[11] ^ lfsr2[1];
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr1 <= 16'hACE1;
            lfsr2 <= 16'h5EED;
        end else begin
            lfsr1 <= {lfsr1[14:0], feedback1};
            lfsr2 <= {lfsr2[14:0], feedback2};
        end
    end
    
    assign lfsr1_raw = lfsr1[3:0];
    assign lfsr2_raw = lfsr2[7:4];
    
    // Validar y ajustar random_card1
    always_comb begin
        automatic logic [3:0] temp1;
        automatic int attempts;
        
        temp1 = lfsr1_raw;
        attempts = 0;
        
        // Buscar primera carta válida (no encontrada)
        while (attempts < 16 && cards_matched[temp1]) begin
            temp1 = (temp1 + 4'd1) & 4'hF;  // Módulo 16
            attempts = attempts + 1;
        end
        
        random_card1 = temp1;
    end
    
    // Validar y ajustar random_card2 (diferente de card1)
    always_comb begin
        automatic logic [3:0] temp2;
        automatic int attempts;
        
        temp2 = lfsr2_raw;
        attempts = 0;
        
        // Buscar segunda carta válida (no encontrada y diferente de card1)
        while (attempts < 16 && (cards_matched[temp2] || temp2 == random_card1)) begin
            temp2 = (temp2 + 4'd1) & 4'hF;  // Módulo 16
            attempts = attempts + 1;
        end
        
        random_card2 = temp2;
    end
endmodule
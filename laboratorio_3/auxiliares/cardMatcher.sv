module cardMatcher(
    input  logic [3:0] carta1_pos,
    input  logic [3:0] carta2_pos,
    output logic       cards_match
);
    logic [2:0] card_values [0:15];
    
    initial begin
        card_values[0]  = 3'd0;  card_values[1]  = 3'd0;
        card_values[2]  = 3'd1;  card_values[3]  = 3'd1;
        card_values[4]  = 3'd2;  card_values[5]  = 3'd2;
        card_values[6]  = 3'd3;  card_values[7]  = 3'd3;
        card_values[8]  = 3'd4;  card_values[9]  = 3'd4;
        card_values[10] = 3'd5;  card_values[11] = 3'd5;
        card_values[12] = 3'd6;  card_values[13] = 3'd6;
        card_values[14] = 3'd7;  card_values[15] = 3'd7;
    end
    
    assign cards_match = (card_values[carta1_pos] == card_values[carta2_pos]) && 
                        (carta1_pos != carta2_pos);
endmodule
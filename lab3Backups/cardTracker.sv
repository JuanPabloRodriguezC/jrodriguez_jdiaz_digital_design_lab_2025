module cardTracker(
    input  logic       clk,
    input  logic       rst,
    input  logic       mark_match,
    input  logic [3:0] carta1_pos,
    input  logic [3:0] carta2_pos,
    
    output logic [15:0] cards_matched,
    output logic        game_over
);
    logic [3:0] match_count;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cards_matched <= 16'h0000;
            match_count <= 4'd0;
        end else begin
            if (mark_match && !cards_matched[carta1_pos] && !cards_matched[carta2_pos]) begin
                cards_matched[carta1_pos] <= 1'b1;
                cards_matched[carta2_pos] <= 1'b1;
                match_count <= match_count + 4'd1;
            end
        end
    end
    
    assign game_over = (match_count >= 4'd8);  // 8 pares encontrados
endmodule
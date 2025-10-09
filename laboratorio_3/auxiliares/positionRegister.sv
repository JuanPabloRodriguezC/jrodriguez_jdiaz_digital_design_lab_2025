module positionRegister(
    input  logic       clk,
    input  logic       rst,
    input  logic       use_random,
    input  logic [1:0] selector_carta,
    input  logic [3:0] cursor_pos,
    input  logic [3:0] random_card1,
    input  logic [3:0] random_card2,
    
    output logic [3:0] carta1_pos,
    output logic [3:0] carta2_pos
);
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            carta1_pos <= 4'h0;
            carta2_pos <= 4'h0;
        end else begin
            if (use_random) begin
                carta1_pos <= random_card1;
                carta2_pos <= random_card2;
            end else begin
                // Cargar posiciones del cursor
                if (selector_carta == 2'b01)
                    carta1_pos <= cursor_pos;
                if (selector_carta == 2'b10)
                    carta2_pos <= cursor_pos;
            end
        end
    end
endmodule
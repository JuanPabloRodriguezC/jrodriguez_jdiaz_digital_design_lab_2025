module scoreKeeper(
    input  logic       clk,
    input  logic       rst,
    input  logic       enable_score1,
    input  logic       enable_score2,
    
    output logic [3:0] puntaje1,
    output logic [3:0] puntaje2
);
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            puntaje1 <= 4'h0;
            puntaje2 <= 4'h0;
        end else begin
            if (enable_score1)
                puntaje1 <= puntaje1 + 4'h1;
            if (enable_score2)
                puntaje2 <= puntaje2 + 4'h1;
        end
    end
endmodule
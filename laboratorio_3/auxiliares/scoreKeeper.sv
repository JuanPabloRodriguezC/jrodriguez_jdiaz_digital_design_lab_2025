module scoreKeeper(
    input  logic       clk,
    input  logic       rst,
    input  logic       enable_score,
    input  logic       turno,

    output logic [3:0] puntaje1,
    output logic [3:0] puntaje2
);
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            puntaje1 <= 4'h0;
            puntaje2 <= 4'h0;
        end else begin
            if (enable_score) begin
                if (turno == 1'b0)
                    puntaje1 <= puntaje1 + 4'h1;
                else
                    puntaje2 <= puntaje2 + 4'h1;
            end
        end
    end
endmodule
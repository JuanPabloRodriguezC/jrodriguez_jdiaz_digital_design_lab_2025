module button_edge (
    input  logic clk,
    input  logic reset_n,
    input  logic button_in,
    output logic button_pulse
);
    logic [1:0] sync;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            sync <= 2'b00;
        else
            sync <= {sync[0], button_in};
    end

    assign button_pulse = (sync[0] & ~sync[1]);
endmodule
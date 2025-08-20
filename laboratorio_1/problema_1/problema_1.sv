module problema_1 #(parameter WIDTH=4)(
    input logic [WIDTH-1:0] binary_in,
    output logic [WIDTH-1:0] gray_out
);
    always_comb begin
        gray_out[WIDTH-1] = binary_in[WIDTH-1];
        for (int i = WIDTH-2; i >= 0; i--) begin
            gray_out[i] = binary_in[i+1] ^ binary_in[i];
		  end
    end
endmodule
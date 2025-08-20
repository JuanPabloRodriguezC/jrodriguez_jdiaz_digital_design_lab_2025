module decoder_segmentos (
    input  logic [3:0] data,
    output logic [6:0] segments
);
    always_comb begin
        case (data)
				4'h0: segments = 7'b1000000;
				4'h1: segments = 7'b1111001;
				4'h2: segments = 7'b0100100;
				4'h3: segments = 7'b0110000;
				4'h4: segments = 7'b0011001;
				4'h5: segments = 7'b0010010;
				4'h6: segments = 7'b0000010;
				4'h7: segments = 7'b1111000;
				4'h8: segments = 7'b0000000;
				4'h9: segments = 7'b0010000;
			endcase
    end
endmodule
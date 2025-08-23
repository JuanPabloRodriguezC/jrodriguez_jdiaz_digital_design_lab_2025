module problema_1 #(parameter WIDTH=4)(
    input logic [WIDTH-1:0] binary_in,

    output logic [WIDTH-1:0] gray_out, 
	  output logic [6:0] seg_out //7 segmentos

);
    always_comb begin
        gray_out[WIDTH-1] = binary_in[WIDTH-1];
        for (int i = WIDTH-2; i >= 0; i--) begin
            gray_out[i] = binary_in[i+1] ^ binary_in[i];
		  end
		  
		  case (gray_out)
				4'h0: seg_out = 7'b1000000;
				4'h1: seg_out = 7'b1111001;
				4'h2: seg_out = 7'b0100100;
				4'h3: seg_out = 7'b0110000;
				4'h4: seg_out = 7'b0011001;
				4'h5: seg_out = 7'b0010010;
				4'h6: seg_out = 7'b0000010;
				4'h7: seg_out = 7'b1111000;
				4'h8: seg_out = 7'b0000000;
				4'h9: seg_out = 7'b0010000;
				4'ha: seg_out = 7'b0001000;
				4'hb: seg_out = 7'b0000011;
				4'hc: seg_out = 7'b1000110;
				4'hd: seg_out = 7'b0100001;
				4'he: seg_out = 7'b0000110;
				4'hf: seg_out = 7'b0001110;
			endcase

    end
endmodule
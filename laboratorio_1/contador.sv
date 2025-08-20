module contador #(parameter WIDTH=8)(
	input logic clk,
	input logic reset_n,
	input logic enable,
	output logic [WIDTH-1:0] count,
	output logic overflow
);
	always_ff @(posedge clk or negedge reset_n) begin
		 if (!reset_n) begin
			  count <= '0;
			  overflow <= 1'b0;
		 end else begin
			  if (enable) begin
					if (count == {WIDTH{1'b1}}) begin
						 count <= '0;
						 overflow <= 1'b1;
					end else begin
						 count <= count + 1'b1;
						 overflow <= 1'b0;
					end
			  end else begin
					overflow <= 1'b0;
			  end
		 end
	end
endmodule
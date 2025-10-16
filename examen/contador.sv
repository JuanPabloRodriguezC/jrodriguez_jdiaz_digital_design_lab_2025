module contador #(parameter int segundos = 10)(
			  input logic clk,
			  input logic rst,
			  input logic enable,
			  
			  output logic timeout
);

	logic [31:0] counter;
	logic [31:0] time_value;
	logic timeout_reg;

always_ff @(posedge clk or posedge rst) begin
	if (rst) begin
		counter <= 0;
		time_value <= segundos;
		timeout_reg <= 1'b0;
  end else if (enable) begin		
		if (counter >= 50_000_000 - 1) begin
			 counter <= 0;
			 
			 if (time_value > 1) begin
				  time_value <= time_value - 1;
				  timeout_reg <= 1'b0;
			 end else begin
				  // activa el registro para mantener timeout cuando este activo
				  timeout_reg <= 1'b1;
			 end
		end else begin
			 counter <= counter + 1;
		end
  end

end

// Mantener timeout_reg cuando enable = 0

assign timeout = timeout_reg;

endmodule

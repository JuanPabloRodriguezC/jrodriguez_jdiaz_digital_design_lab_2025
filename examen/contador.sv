module contador #(parameter int segundos = 10)(
			  input logic clk,
			  input logic rst,
			  input logic enable,
			  
			  output logic timeout
);

	logic [31:0] counter = 0;
	logic [3:0]  time_value;  

always_ff @(posedge clk or posedge rst) begin
	if (rst) begin
		counter <= 0;
		time_value <= 10;
		timeout <= 1'b0;
  end else if (enable) begin
		timeout <= 1'b0;  // Default
		
		if (counter >= 50_000_000 - 1) begin
			 counter <= 0;
			 
			 if (time_value > 0) begin
				  time_value <= time_value - 1;
			 end else begin
				  // Llegó a 0
				  timeout <= 1'b1;
				  time_value <= segundos;  // Reiniciar para próxima vez
			 end
		end else begin
			 counter <= counter + 1;
		end
  end else begin
		// No está habilitado, mantener valor actual
		timeout <= 1'b0;
  end 
end  

endmodule
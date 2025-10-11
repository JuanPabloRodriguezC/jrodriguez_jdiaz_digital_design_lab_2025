module regEstado(
  input clk,
  input reset,
  input [7:0] data_in,
  output logic [7:0] data_out
);
  always_ff @(posedge clk, posedge reset) begin
    if (reset) data_out <= 8'h00;     // arranca en 0
    else data_out <= data_in;         // guarda lo que viene del mux
  end
endmodule
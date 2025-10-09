module regContador(
  input clk,
  input reset,
  input cont,
  output logic [7:0] mantenimiento
);
  always_ff @(posedge clk, posedge reset) begin
    if (reset) mantenimiento <= 0;
    else if (cont) mantenimiento <= mantenimiento + 1;
  end
endmodule

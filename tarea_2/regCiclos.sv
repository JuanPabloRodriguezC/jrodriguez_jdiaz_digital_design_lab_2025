module regCiclos(
  input clk,
  input reset,
  input rst_tiempo,
  output logic t0
);
  logic [7:0] count; // suficiente para contar hasta 200

  always_ff @(posedge clk, posedge reset) begin
    if (reset) count <= 0;             // reset global
    else if (rst_tiempo) count <= 0;   // reinicio por FSM
    else if (count < 200) count <= count + 1;
  end

  assign t0 = (count == 200);
endmodule


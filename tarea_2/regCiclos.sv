module regCiclos(
  input clk,
  input reset,
  input rst_tiempo,
  output logic t0
);
  logic [7:0] count;
  
  always_ff @(posedge clk, posedge reset) begin
    if (reset) count <= 0;             // reset global
    else if (rst_tiempo) count <= 0;   // reinicio por FSM (cuando hay mantenimiento)
    else if (count < 200) count <= count + 1;   // Contador a 200
  end
  
  assign t0 = (count >= 200);          // Señal t0 cuando llega al límite
endmodule


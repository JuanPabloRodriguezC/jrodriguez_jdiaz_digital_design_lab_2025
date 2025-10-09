module main (
  input  logic clk,
  input  logic reset,
  input  logic m,              // botón de mantenimiento
  output logic [7:0] estado    // salida: registro de estado
);
  // Señales internas
  logic cont, rst_tiempo, set_mux; 
  logic t0;
  logic [7:0] mantenimiento;
  logic [7:0] mux_out;  // Señal de salida del mux

  // ============================
  // Instancia de la FSM (control)
  // ============================
  fsm fsm_inst (
    .m(m),
    .t0(t0),
    .clk(clk),
    .reset(reset),
    .rst_tiempo(rst_tiempo),
    .cont(cont),
    .set_mux(set_mux)
  );

  // ============================
  // Instancia del contador de ciclos (200)
  // ============================
  regCiclos regCiclos_inst (
    .clk(clk),
    .reset(reset),
    .rst_tiempo(rst_tiempo),
    .t0(t0)
  );

  // ============================
  // Instancia del contador de mantenimientos
  // ============================
  regContador regContador_inst (
    .clk(clk),
    .reset(reset),
    .cont(cont),
    .mantenimiento(mantenimiento)
  );

  // ============================
  // Instancia del mux
  // ============================
  mux2 mux_inst (
    .d0(mantenimiento),
    .d1(8'hFF),  
    .set_mux(set_mux),
    .y(mux_out)  

  // ============================
  // Instancia del registro de estado
  // ============================
  regEstado regEstado_inst (
    .clk(clk),
    .reset(reset),
    .data_in(mux_out),  
    .data_out(estado)   
  );

endmodule

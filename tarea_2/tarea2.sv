module tarea2 (
  input  logic clk,
  input  logic reset,
  input  logic m,              // botón de mantenimiento
  output logic [7:0] estado    // salida: registro de estado
);

  // Señales internas
  logic cont, rst_tiempo, set_mux; 
  logic t0;
  logic [7:0] mantenimiento;
  logic [7:0] data_in;

  // ============================
  // Instancia de la FSM (control)
  // ============================
  FSM fsm_inst (
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
  mux mux_inst (
    .mantenimiento(mantenimiento),
    .set_mux(set_mux),
    .data_in(data_in)
  );

  // ============================
  // Instancia del registro de estado
  // ============================
  regEstado regEstado_inst (
    .clk(clk),
    .reset(reset),
    .data_in(data_in),
    .estado(estado)
  );

endmodule

module fsm(input m, t0, clk, reset, output rst_tiempo, cont, set_mux);
  typedef enum logic [1:0] {S0, S1, S2, S3} statetype;
  statetype state, next_state;
  
  // actual state logic
  always_ff @(posedge clk, posedge reset)
    if (reset) state <= S0;
    else state <= next_state;
    
  // next state logic
  always_comb
    case (state)
      S0: if(m) next_state = S1;           // Si presiona m, va a mantenimiento
          else next_state = S2;            // Si no presiona, va a verificar tiempo
      S1: next_state = S0;                 // Mantenimiento regresa inmediatamente a S0
      S2: if(t0) next_state = S3;          // Si llegó al límite, va a mostrar error
          else next_state = S0;            // Si no llegó al límite, regresa a esperar
      S3: if (reset) next_state =S0; next_state = S3;                 // Se queda mostrando hasta reset global
      default: next_state = S0;
    endcase
	 
// outputs logic - Solo señales de control
  assign cont = (state == S1);           // Incrementar contador solo en S1
  assign rst_tiempo = (state == S1);     // Reiniciar tiempo solo en S1  
  assign set_mux = (state == S3);        // Mostrar contador solo en S3 

endmodule
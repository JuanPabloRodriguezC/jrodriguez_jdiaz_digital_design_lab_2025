module card_position_randomizer(
  input  logic        clk,
  input  logic        rst,
  input  logic [7:0]  seed,       // Semilla para variar la aleatorización
  output logic [3:0]  positions [0:15]  // Mapeo: carta[i] va a posición positions[i]
);

  // LFSR para generar números pseudo-aleatorios
  logic [15:0] lfsr;
  logic        feedback;
  
  // Array temporal para algoritmo de Fisher-Yates
  logic [3:0] temp_positions [0:15];
  logic [3:0] swap_idx;
  logic [4:0] init_counter;
  logic       initialized;
  
  // Feedback para LFSR de 16 bits (polinomio: x^16 + x^15 + x^13 + x^4 + 1)
  assign feedback = lfsr[15] ^ lfsr[14] ^ lfsr[12] ^ lfsr[3];
  
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      // Inicializar LFSR con semilla
      lfsr <= {seed, 8'hA5};  // Combinar semilla con valor fijo
      if (lfsr == 16'h0000) lfsr <= 16'hACE1;  // Evitar estado 0
      
      // Inicializar posiciones en orden
      for (int i = 0; i < 16; i++) begin
        temp_positions[i] <= i[3:0];
      end
      
      init_counter <= 5'd0;
      initialized  <= 1'b0;
      
    end else if (!initialized) begin
      // Algoritmo de Fisher-Yates para barajar
      // En cada ciclo, intercambiamos una posición
      
      // Avanzar LFSR
      lfsr <= {lfsr[14:0], feedback};
      
      // Calcular índice de intercambio (0 a init_counter)
      if (init_counter < 16) begin
        // Usar módulo para limitar el rango
        swap_idx = (lfsr[3:0] % (init_counter + 1));
        
        // Intercambiar temp_positions[init_counter] con temp_positions[swap_idx]
        temp_positions[init_counter] <= temp_positions[swap_idx];
        temp_positions[swap_idx]     <= temp_positions[init_counter];
        
        init_counter <= init_counter + 1'b1;
      end else begin
        initialized <= 1'b1;
      end
    end
  end
  
  // Asignar salida
  always_comb begin
    if (initialized) begin
      positions = temp_positions;
    end else begin
      // Durante inicialización, mantener orden secuencial
      for (int i = 0; i < 16; i++) begin
        positions[i] = i[3:0];
      end
    end
  end

endmodule
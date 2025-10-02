module main_tb;
  // Señales del testbench
  logic clk;
  logic reset;
  logic m;
  logic [7:0] estado;

  // Instancia del módulo main
  main dut (
    .clk(clk),
    .reset(reset),
    .m(m),
    .estado(estado)
  );

  // Generación de reloj: 10ns de periodo (100MHz)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Proceso de prueba
  initial begin
    $display("===== Inicio de simulación =====");
    $display("Tiempo | Reset | M | Estado | Descripción");
    $display("-------|-------|---|--------|-------------");
    
    // Inicialización
    reset = 1;
    m = 0;
    #20;
    
    // Quitar reset
    reset = 0;
    $display("%6t |   0   | 0 |  %3d   | Sistema iniciado", $time, estado);
    #50;
    
    // ============================
    // TEST 1: Activar mantenimiento (m=1)
    // ============================
    $display("\n--- TEST 1: Activar mantenimiento ---");
    m = 1;
    #10;  // Un ciclo con m=1
    $display("%6t |   0   | 1 |  %3d   | m activado (FSM: S0->S1)", $time, estado);
    
    m = 0;
    #10;  // Siguiente ciclo
    $display("%6t |   0   | 0 |  %3d   | Contador incrementado (FSM: S1->S0)", $time, estado);
    #50;
    
    // ============================
    // TEST 2: Múltiples mantenimientos
    // ============================
    $display("\n--- TEST 2: Realizar 3 mantenimientos ---");
    repeat(3) begin
      m = 1;
      #10;
      $display("%6t |   0   | 1 |  %3d   | Mantenimiento solicitado", $time, estado);
      m = 0;
      #10;
      $display("%6t |   0   | 0 |  %3d   | Contador = %d", $time, estado, estado);
      #20;
    end
    
    // ============================
    // TEST 3: Esperar 200 ciclos sin mantenimiento
    // ============================
    $display("\n--- TEST 3: Esperar 200 ciclos (t0=1) ---");
    $display("Esperando 200 ciclos...");
    #2000;  // 200 ciclos de reloj
    $display("%6t |   0   | 0 |  %3d   | Después de 200 ciclos (estado debe ser 0xFF)", $time, estado);
    
    // Verificar que estado = 0xFF (set_mux activo en S3)
    if (estado == 8'hFF) begin
      $display("✓ PASS: Estado = 0xFF correctamente en S3");
    end else begin
      $display("✗ FAIL: Estado = %h, se esperaba 0xFF", estado);
    end
    
    #100;
    
    // ============================
    // TEST 4: Reset durante S3
    // ============================
    $display("\n--- TEST 4: Reset global ---");
    reset = 1;
    #20;
    $display("%6t |   1   | 0 |  %3d   | Reset activado", $time, estado);
    
    reset = 0;
    #10;
    $display("%6t |   0   | 0 |  %3d   | Sistema reiniciado", $time, estado);
    
    if (estado == 8'h00) begin
      $display("✓ PASS: Estado reiniciado a 0x00");
    end else begin
      $display("✗ FAIL: Estado = %h después de reset", estado);
    end
    
    // ============================
    // TEST 5: Secuencia completa
    // ============================
    $display("\n--- TEST 5: Secuencia completa ---");
    
    // Hacer 5 mantenimientos
    repeat(5) begin
      m = 1;
      #10;
      m = 0;
      #10;
    end
    $display("%6t |   0   | 0 |  %3d   | Después de 5 mantenimientos", $time, estado);
    
    // Esperar 200 ciclos
    #2000;
    $display("%6t |   0   | 0 |  %3d   | Después de 200 ciclos (debe ser 0xFF)", $time, estado);
    
    // Reset para salir de S3
    reset = 1;
    #20;
    reset = 0;
    #10;
    $display("%6t |   0   | 0 |  %3d   | Después de reset", $time, estado);
    
    // ============================
    // TEST 6: Verificar que contador no supera 200
    // ============================
    $display("\n--- TEST 6: Verificar límite de contador ---");
    #2500;  // Más de 200 ciclos
    $display("%6t |   0   | 0 |  %3d   | Después de >200 ciclos adicionales", $time, estado);
    $display("(Debe permanecer en S3 con estado = 0xFF)");
    
    #50;
    $display("\n===== Fin de simulación =====");
    $finish;
  end

  // Monitor para debugging (opcional, comentar si genera mucha salida)
  /*
  initial begin
    $monitor("Tiempo=%6t | reset=%b | m=%b | estado=%3d (0x%h)", 
             $time, reset, m, estado, estado);
  end
  */

  // Generación de forma de onda (para GTKWave, ModelSim, etc.)
  initial begin
    $dumpfile("tb_main.vcd");
    $dumpvars(0, tb_main);
  end

endmodule

module top_lab3(
  // Clock y Reset
  input  logic        clk,          // clock de placa (50 MHz) para VGA y FSM
  input  logic        rst_n,        // reset activo en bajo
  
  // VGA Outputs
  output logic        hsync,
  output logic        vsync,
  output logic        vga_clk,
  output logic        vga_blank_n,
  output logic        vga_sync_n,
  output logic [7:0]  vga_r,
  output logic [7:0]  vga_g,
  output logic [7:0]  vga_b,
  
  // 7-Segment Displays
  output logic [6:0]  seg_units,    // 7-segment units
  output logic [6:0]  seg_tens,     // 7-segment tens
  
  // FSM Inputs
  input  logic        rst,           // Reset para FSM (adicional a rst_n)
  input  logic        carta_recibida,
  input  logic [3:0]  card_id,       
  input  logic [3:0]  random_card1,
  input  logic [3:0]  random_card2,
  
  // FSM Outputs
  output logic [3:0]  carta1,
  output logic [3:0]  carta2,
  output logic [3:0]  puntaje1,
  output logic [3:0]  puntaje2,
  output logic        turno,
  output logic [4:0]  num_cartas_disponibles,
  output logic        timer_reset,
  output logic        timer_enable,
  output logic [2:0]  state_out 
);

  // ===== 1) Pixel clock =====
  logic vgaclk;
  
`ifdef USE_PLL
  pll vgapll(.inclk0(clk), .c0(vgaclk));
`else
  gen_pixclk #(
    .SYS_CLK_HZ(50_000_000),
    .PIX_CLK_HZ(25_000_000)
  ) u_pix (
    .clk    (clk),
    .rst    (~rst_n),
    .clk_pix(vgaclk)
  );
`endif

  assign vga_clk    = vgaclk;
  assign vga_sync_n = 1'b1;

  // ===== 2) VGA Controller =====
  logic [9:0] x, y;
  logic       blank_b;
  
  vgaController u_ctrl(
    .vgaclk (vgaclk),
    .rst    (~rst_n),
    .hsync  (hsync),
    .vsync  (vsync),
    .sync_b (),
    .blank_b(blank_b),
    .x      (x),
    .y      (y)
  );
  
  assign vga_blank_n = blank_b;

  // ===== 3) Timer (countdown from 15) =====
  logic [3:0] timer_value;
  logic       timer_timeout_internal;  // Señal interna del timer
  
  timer #(
    .CLOCK_FREQ(50_000_000)
  ) u_timer (
    .clk            (clk),
    .rst            (timer_reset),      // Usar timer_reset de la FSM
    .enable         (timer_enable),     // Usar timer_enable de la FSM
    .timeout        (timer_timeout_internal),
    .segments_units (seg_units),
    .segments_tens  (seg_tens),
    .count_value    (timer_value)
  );

    // ===== 4) Generador de Posiciones Aleatorias =====
  logic [3:0] card_positions [0:15];  // Índices aleatorios para cada carta
  
  card_position_randomizer u_randomizer(
    .clk      (clk),
    .rst      (~rst_n | rst),  // Reset con rst_n o rst de FSM
    .seed     ({random_card1, random_card2}),  // Semilla de 8 bits
    .positions(card_positions)
  );

  // ===== 5) Video Generation =====
  videoGen u_vid(
    .x(x),
    .y(y),
    .r(vga_r),
    .g(vga_g),
    .b(vga_b)
  );

  // ===== 6) FSM =====
  FSM u_FSM(
    // Inputs
    .clk                     (clk),
    .rst                     (rst),
    .carta_recibida          (carta_recibida),
    .card_id                (card_id),
    .timer_timeout           (timer_timeout_internal),  // Conectar señal interna
    .random_card1            (random_card1),
    .random_card2            (random_card2),
    
    // Outputs
    .carta1                  (carta1),
    .carta2                  (carta2),
    .puntaje1                (puntaje1),
    .puntaje2                (puntaje2),
    .turno                   (turno),
    .num_cartas_disponibles  (num_cartas_disponibles),
    .timer_reset             (timer_reset),
    .timer_enable            (timer_enable),
    .state_out               (state_out)
  );

endmodule
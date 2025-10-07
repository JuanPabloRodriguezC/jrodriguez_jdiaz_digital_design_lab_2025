module top_lab3(
  // Clock y Reset
  input  logic        clk,          // clock de placa (50 MHz)
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
  output logic [6:0]  seg_units,
  output logic [6:0]  seg_tens,
  
  // Botones para control de cursor (KEY[3:0])
  input  logic [3:0]  KEY,          // KEY[0]=select, KEY[1]=right, KEY[2]=left, KEY[3]=down
  input  logic [1:0]  SW,           // SW[0]=up (ejemplo adicional)
  
  // FSM Inputs
  input  logic        rst,           // Reset para FSM
  
  // FSM Outputs
  output logic [3:0]  carta1,
  output logic [3:0]  carta2,
  output logic [3:0]  puntaje1,
  output logic [3:0]  puntaje2,
  output logic        turno,
  output logic [4:0]  num_cartas_disponibles,
  output logic        timer_reset,
  output logic        timer_enable,
  output logic [2:0]  state_out,
  
  // Debug outputs
  output logic [3:0]  cursor_pos_debug  // Ver posición del cursor en LEDs
);

  // ===== Señales internas =====
  logic [3:0] cursor_position;
  logic       card_selected_pulse;
  logic [3:0] selected_card_id;
  
  // Botones invertidos (activos en bajo en la placa)
  logic btn_select, btn_right, btn_left, btn_down, btn_up;
  assign btn_select = ~KEY[0];
  assign btn_right  = ~KEY[1];
  assign btn_left   = ~KEY[2];
  assign btn_down   = ~KEY[3];
  assign btn_up     = SW[0];  // Usar switch para UP
  
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
  
  // ===== 3) Timer =====
  logic [3:0] timer_value;
  logic       timer_timeout_internal;
  
  timer #(
    .CLOCK_FREQ(50_000_000)
  ) u_timer (
    .clk            (clk),
    .rst            (timer_reset),
    .enable         (timer_enable),
    .timeout        (timer_timeout_internal),
    .segments_units (seg_units),
    .segments_tens  (seg_tens),
    .count_value    (timer_value)
  );
  
  // ===== 4) Controlador de Cursor =====
  cursor_controller u_cursor(
    .clk           (clk),
    .rst           (rst),
    .btn_up        (btn_up),
    .btn_down      (btn_down),
    .btn_left      (btn_left),
    .btn_right     (btn_right),
    .btn_select    (btn_select),
    .cursor_pos    (cursor_position),
    .card_selected (card_selected_pulse),
    .selected_id   (selected_card_id)
  );
  
  // Debug: mostrar posición del cursor
  assign cursor_pos_debug = cursor_position;
  
  // ===== 5) Generador de Posiciones Aleatorias =====
  logic [3:0] card_positions [0:15];
  
  card_position_randomizer u_randomizer(
    .clk      (clk),
    .rst      (~rst_n | rst),
    .seed     ({random_card1, random_card2}),
    .positions(card_positions)
  );
  
  // ===== 6) Video Generation con Cursor =====
  videoGen u_vid(
    .x         (x),
    .y         (y),
    .cursor_pos(cursor_position),  // Mostrar cursor en VGA
    .r         (vga_r),
    .g         (vga_g),
    .b         (vga_b)
  );
  
  // ===== 7) FSM =====
  FSM u_FSM(
    // Inputs
    .clk                     (clk),
    .rst                     (rst),
    .carta_recibida          (card_selected_pulse),      // Del cursor
    .card_id                 (selected_card_id),         // Del cursor
    .timer_timeout           (timer_timeout_internal),
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
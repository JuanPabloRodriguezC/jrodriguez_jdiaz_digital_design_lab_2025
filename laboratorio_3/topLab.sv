module topLab(
  // Clock y Reset
  input  logic        clk,          // clock de placa (50 MHz)
  input  logic        rst_n,        // reset activo en bajo

  // Botones para control de cursor (KEY[3:0])
  input  logic [3:0]  KEY,          // KEY[0]=select, KEY[1]=right, KEY[2]=left, KEY[3]=down
  input  logic [1:0]  SW,           // SW[0]=up (ejemplo adicional)
  
  // FSM Inputs
  input  logic        rst,           // Reset para FSM
  
  // 7-Segment Displays
  output logic [6:0]  seg_units,
  output logic [6:0]  seg_tens,
  output logic [6:0]  seg_puntaje_1,
  output logic [6:0]  seg_puntaje_2,     
  
  // Debug outputs
  output logic [3:0]  cursor_pos_debug  // Ver posición del cursor en LEDs
);

  logic [3:0]  puntaje1,
  logic [3:0]  puntaje2,

  // VGA Outputs
  logic        hsync,
  logic        vsync,
  logic        vga_clk,
  logic        vga_blank_n,
  logic        vga_sync_n,
  logic [7:0]  vga_r,
  logic [7:0]  vga_g,
  logic [7:0]  vga_b,

  // ===== Señales internas =====
  logic [3:0] cursor_position;
  logic       card_selected_pulse;
  logic [3:0] selected_card_id;

  // FSM Outputs
  logic [3:0]  carta1,
  logic [3:0]  carta2,
  logic        turno,
  logic [4:0]  num_cartas_disponibles,
  logic        timer_reset,
  logic        timer_enable,
  logic [2:0]  state_out,
  
  // Botones invertidos (activos en bajo en la placa)
  logic btn_select, btn_right, btn_left, btn_down, btn_up;
  assign btn_select = ~KEY[0];
  assign btn_right  = ~KEY[1];
  assign btn_left   = ~KEY[2];
  assign btn_down   = ~KEY[3];
  assign btn_up     = SW[0];  // Usar switch para UP

  // ===== 2) VGA Controller =====
  logic [9:0] x, y;
  assign vga_sync_n = 1'b1;

  // ===== 3) Timer =====
  logic [3:0] timer_value;
  logic       timer_timeout_internal;
  
  genPixClock #(
    .SYS_CLK_HZ(50_000_000),
    .PIX_CLK_HZ(25_000_000)
  ) u_pix (
    .clk    (clk),
    .rst    (~rst_n),
    .clk_pix(vga_clk)
  );  
  
  vgaController u_ctrl(
    .vgaclk (vgaclk),
    .rst    (~rst_n),
    .hsync  (hsync),
    .vsync  (vsync),
    .sync_b (vga_sync_n),
    .blank_b(vga_blank_b),
    .x      (x),
    .y      (y)
  );
  
  timer #(
    .CLOCK_FREQ(50_000_000)
  ) u_timer (
    .clk            (clk),
    .rst            (timer_reset),
    .enable         (timer_enable),
    .timeout        (timer_timeout_internal),
    .segments_units (seg_units),
    .segments_tens  (seg_tens)
  );
  
  // ===== 4) Controlador de Cursor =====
  cursorController u_cursor(
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
  
  cardPositionRandomizer u_randomizer(
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
  fsm u_FSM(
    // Inputs
    .clk                     (clk),
    .rst                     (rst),
    .carta_recibida          (carta_recibida),
    .timer_timeout           (timer_timeout_internal),
    .carta1_reg              (carta1),
    .carta2_reg              (carta2),
    
    // Outputs
    .turno                   (turno),
    .selector_carta          (selector_carta),
    .timer_reset             (timer_reset),
    .timer_enable            (timer_enable),
    .sig_carta_aleatoria     (sig_carta_aleatoria)
  );
  
endmodule
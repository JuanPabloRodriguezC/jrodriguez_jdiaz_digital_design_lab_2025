module topLab(
  // Clock y Reset
  input  logic        clk,          // clock de placa (50 MHz)
  input  logic        rst_n,        // reset activo en bajo

  // Botones para control de cursor (KEY[3:0])
  input  logic [3:0]  KEY,          // KEY[0]=select, KEY[1]=right, KEY[2]=left, KEY[3]=down
  input  logic [1:0]  SW,           // SW[0]=up, SW[1]=rst para FSM
  
  // VGA Outputs
  output logic        VGA_HS,
  output logic        VGA_VS,
  output logic        VGA_CLK,       // Reloj VGA para el DAC
  output logic        VGA_BLANK_N,
  output logic        VGA_SYNC_N,
  output logic [7:0]  VGA_R,
  output logic [7:0]  VGA_G,
  output logic [7:0]  VGA_B,
  
  // 7-Segment Displays
  output logic [6:0]  HEX0,         // Unidades timer
  output logic [6:0]  HEX1,         // Decenas timer
  output logic [6:0]  HEX2,         // Puntaje jugador 1
  output logic [6:0]  HEX3,         // Puntaje jugador 2
  
  // Debug outputs
  output logic [3:0]  LEDR          // Ver posición del cursor en LEDs
);

  // ===== Señales internas =====
  logic [3:0] cursor_position;
  logic       carta_recibida;
  logic [3:0] carta1_id, carta2_id;
  
  // FSM señales
  logic       selector_carta;
  logic       turno;
  logic       timer_reset;
  logic       timer_enable;
  logic [3:0] puntaje1;
  logic [3:0] puntaje2;
  logic       sig_carta_aleatoria;
  
  // VGA señales
  logic [9:0] x, y;
  logic       vga_clk;
  
  // Timer señales
  logic       timer_timeout_internal;
  
  // Botones procesados (activos en bajo en la placa)
  logic btn_select, btn_right, btn_left, btn_down, btn_up;
  logic rst_fsm;

  assign btn_select = ~KEY[0];
  assign btn_right  = ~KEY[1];
  assign btn_left   = ~KEY[2];
  assign btn_down   = ~KEY[3];
  assign btn_up     = SW[0];
  assign rst_fsm    = SW[1];

  // Asignaciones VGA
  assign VGA_HS = hsync;
  assign VGA_VS = vsync;
  assign VGA_CLK = vga_clk;          // Reloj para el DAC VGA
  assign VGA_BLANK_N = vga_blank_n;
  assign VGA_SYNC_N = vga_sync_n;
  assign VGA_R = vga_r;
  assign VGA_G = vga_g;
  assign VGA_B = vga_b;
  
  // Debug: mostrar posición del cursor
  assign LEDR = cursor_position;
  
  // ===== Señales VGA internas =====
  logic hsync, vsync, vga_blank_n, vga_sync_n;
  logic [7:0] vga_r, vga_g, vga_b;

  // ===== 1) Generador de reloj de píxeles VGA =====
  genPixClock #(
    .SYS_CLK_HZ(50_000_000),
    .PIX_CLK_HZ(25_000_000)
  ) u_pix (
    .clk    (clk),
    .rst    (~rst_n),
    .clk_pix(vga_clk)
  );  
  
  // ===== 2) VGA Controller =====
  vgaController u_ctrl(
    .vgaclk (vga_clk),      // Usar el reloj generado
    .rst    (~rst_n),
    .hsync  (hsync),
    .vsync  (vsync),
    .sync_b (vga_sync_n),
    .blank_b(vga_blank_n),
    .x      (x),
    .y      (y)
  );
  
  // ===== 3) Timer =====
  timer #(
    .CLOCK_FREQ(50_000_000)
  ) u_timer (
    .clk            (clk),
    .rst            (timer_reset),
    .enable         (timer_enable),
    .timeout        (timer_timeout_internal),
    .segments_units (HEX0),
    .segments_tens  (HEX1)
  );
  
  // ===== 4) Controlador de Cursor =====
  cursorController u_cursor(
    .clk           (clk),
    .rst           (rst_fsm),
    .btn_up        (btn_up),
    .btn_down      (btn_down),
    .btn_left      (btn_left),
    .btn_right     (btn_right),
    .btn_select    (btn_select),
    .selector_carta(selector_carta),
    .cursor_pos    (cursor_position),
    .carta_recibida(carta_recibida),
    .carta1_id     (carta1_id),
    .carta2_id     (carta2_id)
  );
  
  // ===== 5) FSM del juego =====
  fsm u_fsm(
    .clk                 (clk),
    .rst                 (rst_fsm),
    .carta_recibida      (carta_recibida),
    .timer_timeout       (timer_timeout_internal),
    .carta1_reg          (carta1_id),
    .carta2_reg          (carta2_id),
    
    .turno               (turno),
    .selector_carta      (selector_carta),
    .timer_reset         (timer_reset),
    .timer_enable        (timer_enable),
    .puntaje1_reg        (puntaje1),
    .puntaje2_reg        (puntaje2),
    .sig_carta_aleatoria (sig_carta_aleatoria)
  );
  
  // ===== 6) Video Generation con Cursor =====
  videoGen u_vid(
    .x         (x),
    .y         (y),
    .cursor_pos(cursor_position),
    .r         (vga_r),
    .g         (vga_g),
    .b         (vga_b)
  );
  
  // ===== 7) Displays de puntaje (conversión BCD a 7 segmentos) =====
  bcd_to_7seg u_p1_display(
    .bcd(puntaje1),
    .segments(HEX2)
  );
  
  bcd_to_7seg u_p2_display(
    .bcd(puntaje2),
    .segments(HEX3)
  );

endmodule

// Módulo auxiliar para convertir BCD a 7 segmentos
module bcd_to_7seg(
  input  logic [3:0] bcd,
  output logic [6:0] segments
);
  always_comb begin
    case (bcd)
      4'h0: segments = 7'b1000000; // 0
      4'h1: segments = 7'b1111001; // 1
      4'h2: segments = 7'b0100100; // 2
      4'h3: segments = 7'b0110000; // 3
      4'h4: segments = 7'b0011001; // 4
      4'h5: segments = 7'b0010010; // 5
      4'h6: segments = 7'b0000010; // 6
      4'h7: segments = 7'b1111000; // 7
      4'h8: segments = 7'b0000000; // 8
      4'h9: segments = 7'b0010000; // 9
      default: segments = 7'b1111111; // Apagado
    endcase
  end
endmodule
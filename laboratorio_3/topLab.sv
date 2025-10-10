module topLab(
  input  logic        clk,
  input  logic        rst_n,
  input  logic [3:0]  KEY,
  input  logic [1:0]  SW,
  
  output logic        VGA_HS,
  output logic        VGA_VS,
  output logic        VGA_CLK,
  output logic        VGA_BLANK_N,
  output logic        VGA_SYNC_N,
  output logic [7:0]  VGA_R,
  output logic [7:0]  VGA_G,
  output logic [7:0]  VGA_B,
  
  output logic [6:0]  HEX0,
  output logic [6:0]  HEX1,
  output logic [6:0]  HEX2,
  output logic [6:0]  HEX3,
  
  output logic [3:0]  LEDR
);

  // Señales de control de la FSM
  logic       enable_score;
  logic       mark_match, clear_selection;
  logic [1:0] selector_carta;
  logic       timer_reset, timer_enable;
  logic       request_random, random_ready, use_random;
  
  // Señales de status hacia la FSM
  logic       cards_match;
  logic       game_over;
  logic       carta_recibida;
  logic       timer_timeout;
  
  // Señales de datos entre módulos
  logic [3:0] cursor_position;
  logic [3:0] carta1_pos, carta2_pos;
  logic [3:0] random_card1, random_card2;
  logic [3:0] puntaje1, puntaje2;
  logic [15:0] cards_face_up;
  logic [15:0] cards_matched;
  logic       turno;
  
  // VGA señales
  logic [9:0] x, y;
  logic       vga_clk;
  logic       hsync, vsync, vga_blank_n, vga_sync_n;
  logic [7:0] vga_r, vga_g, vga_b;
  
  // Botones procesados
  logic btn_select, btn_right, btn_left, btn_down, btn_up;
  logic rst_fsm;

  assign btn_up     = ~KEY[0];
  assign btn_right  = ~KEY[1];
  assign btn_left   = ~KEY[2];
  assign btn_down   = ~KEY[3];
  assign btn_select = SW[0];
  assign rst_fsm    = SW[1];

  assign VGA_HS = hsync;
  assign VGA_VS = vsync;
  assign VGA_CLK = vga_clk;
  assign VGA_BLANK_N = vga_blank_n;
  assign VGA_SYNC_N = vga_sync_n;
  assign VGA_R = vga_r;
  assign VGA_G = vga_g;
  assign VGA_B = vga_b;
  assign LEDR = cursor_position;

  // ===== 1) Generador de reloj VGA =====
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
    .vgaclk (vga_clk),
    .rst    (~rst_n),
    .hsync  (hsync),
    .vsync  (vsync),
    .sync_b (vga_sync_n),
    .blank_b(vga_blank_n),
    .x      (x),
    .y      (y)
  );

  videoGen u_vid(
    .x            (x),
    .y            (y),
    .cursor_pos   (cursor_position),
    .cards_face_up(display_cards),
    .turno        (turno),
    .game_over    (game_over),
    .puntaje1     (puntaje1),
    .puntaje2     (puntaje2),
    .r            (vga_r),
    .g            (vga_g),
    .b            (vga_b)
  );
  
  // ===== 3) Timer =====
  timer #(
    .CLOCK_FREQ(50_000_000)
  ) u_timer (
    .clk            (clk),
    .rst            (timer_reset),
    .enable         (timer_enable),
    .timeout        (timer_timeout),
    .segments_units (HEX0),
    .segments_tens  (HEX1)
  );

  // ===== 4) Generador Aleatorio =====
  randomGenerator u_random(
    .clk         (clk),
    .rst         (rst_fsm),
    .request_random(request_random),
    .cards_matched(cards_matched),
    .random_card1(random_card1),
    .random_card2(random_card2),
    .random_ready(random_ready)
  );
  
  // ===== 5) Controlador de Cursor =====
  cursorController u_cursor(
    .clk           (clk),
    .rst           (rst_fsm),
    .btn_up        (btn_up),
    .btn_down      (btn_down),
    .btn_left      (btn_left),
    .btn_right     (btn_right),
    .btn_select    (btn_select),
    .selector_carta(selector_carta),
    .cards_matched (cards_matched),
    .cursor_pos    (cursor_position),
    .carta_recibida(carta_recibida)
  );
  
  // ===== 6) Registro de Posiciones =====
  positionRegister u_pos_reg(
    .clk          (clk),
    .rst          (rst_fsm),
    .use_random   (use_random),
    .selector_carta(selector_carta),
    .cursor_pos   (cursor_position),
    .random_card1 (random_card1),
    .random_card2 (random_card2),
    .carta1_pos   (carta1_pos),
    .carta2_pos   (carta2_pos)
  );
  
  // ===== 7) Comparador de Cartas =====
  cardMatcher u_matcher(
    .carta1_pos  (carta1_pos),
    .carta2_pos  (carta2_pos),
    .cards_match (cards_match)
  );
  
  // ===== 8) Registro de Cartas Encontradas =====
  cardTracker u_tracker(
    .clk           (clk),
    .rst           (rst_fsm),
    .mark_match    (mark_match),
    .carta1_pos    (carta1_pos),
    .carta2_pos    (carta2_pos),
    .cards_matched (cards_matched),
    .game_over     (game_over)
  );
  
  // ===== 9) Controlador de Puntajes =====
  scoreKeeper u_score(
    .clk           (clk),
    .rst           (rst_fsm),
    .enable_score (enable_score),
    .turno         (turno),
    .puntaje1      (puntaje1),
    .puntaje2      (puntaje2)
  );
  
  // ===== 10) FSM del juego (SOLO CONTROL) =====
  fsm u_fsm(
    .clk              (clk),
    .rst              (rst_fsm),
    .carta_recibida   (carta_recibida),
    .timer_timeout    (timer_timeout),
    .cards_match      (cards_match),
    .game_over        (game_over),
    .carta1_pos       (carta1_pos),
    .carta2_pos       (carta2_pos),
    .random_ready     (random_ready),
    
    .enable_score     (enable_score),
    .mark_match       (mark_match),
    .selector_carta   (selector_carta),
    .timer_reset      (timer_reset),
    .timer_enable     (timer_enable),
    .request_random   (request_random),
    .use_random       (use_random),
    .turno            (turno),
    .cards_face_up    (cards_face_up)
    
  );
  
  // ===== 11) Video Generation =====
  logic [15:0] display_cards;
  assign display_cards = cards_face_up | cards_matched;  // Mostrar cartas volteadas O encontradas
  
  // ===== 12) Displays de puntaje =====
  bcd_to_7seg u_p1_display(
    .bcd(puntaje1),
    .segments(HEX2)
  );
  
  bcd_to_7seg u_p2_display(
    .bcd(puntaje2),
    .segments(HEX3)
  );

endmodule
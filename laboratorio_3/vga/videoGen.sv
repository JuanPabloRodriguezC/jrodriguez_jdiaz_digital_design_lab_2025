// videoGen.sv — Genera cartas de memoria (8 pares) en grid 4x4
// MODO_A: Cartas con símbolos simples (sin ROM) -> define NO_CHARROM
// MODO_B: Cartas con caracteres desde ROM (requiere charrom.txt en el proyecto)
module videoGen(
  input  logic [9:0] x,
  input  logic [9:0] y,
  output logic [7:0] r,
  output logic [7:0] g,
  output logic [7:0] b
);
`ifdef NO_CHARROM
  // --- MODO_A: Cartas con símbolos simples ---
  logic [15:0] incard;
  logic [15:0] symbol_pixel;
  
  // Grid 4x4 de cartas: 640x480 -> cada celda ~160x120
  // Cartas de 80x60, centradas en cada celda
  genvar i, j;
  generate
    for (i = 0; i < 4; i++) begin : row
      for (j = 0; j < 4; j++) begin : col
        localparam logic [9:0] LEFT   = 10'd40  + j * 10'd160;
        localparam logic [9:0] TOP    = 10'd30  + i * 10'd120;
        localparam logic [9:0] RIGHT  = LEFT + 10'd80;
        localparam logic [9:0] BOTTOM = TOP  + 10'd60;
        localparam int CARD_ID = i*4 + j;
        
        rectgen u_card(
          .x(x), .y(y),
          .left(LEFT), .top(TOP), .right(RIGHT), .bot(BOTTOM),
          .inrect(incard[CARD_ID])
        );
      end
    end
  endgenerate
  
  // Calcula símbolos para todas las cartas
  always_comb begin
    for (int k = 0; k < 16; k++) begin
      automatic logic [9:0] LEFT_k   = 10'd40 + (k%4) * 10'd160;
      automatic logic [9:0] TOP_k    = 10'd30 + (k/4) * 10'd120;
      automatic logic [9:0] card_x_k = x - LEFT_k;
      automatic logic [9:0] card_y_k = y - TOP_k;
      automatic int symbol_id = k / 2;
      
      symbol_pixel[k] = get_symbol_pixel(card_x_k, card_y_k, symbol_id);
    end
  end
  
  // Función para generar píxeles de símbolos
  function automatic logic get_symbol_pixel(
    input logic [9:0] cx,
    input logic [9:0] cy,
    input int sid
  );
    logic [9:0] sx, sy;
    logic in_area;
    
    sx = cx - 10'd28;
    sy = cy - 10'd14;
    in_area = (cx >= 28) && (cx < 52) && (cy >= 14) && (cy < 46);
    
    if (!in_area) return 1'b0;
    
    case (sid)
      // Número 0: Rectángulo
      0: return ((sx >= 6 && sx < 18) && (sy < 2 || sy >= 30)) ||
                ((sy >= 2 && sy < 30) && (sx < 2 || sx >= 22));
      
      // Número 1: Línea vertical
      1: return (sx >= 10 && sx < 14);
      
      // Número 2: Dos líneas horizontales
      2: return (sy >= 8 && sy < 12) || (sy >= 20 && sy < 24);
      
      // Número 3: Tres líneas horizontales
      3: return (sy >= 4 && sy < 8) || (sy >= 14 && sy < 18) || (sy >= 24 && sy < 28);
      
      // Número 4: Cruz
      4: return ((sx >= 10 && sx < 14)) || ((sy >= 14 && sy < 18));
      
      // Número 5: Cuadrado
      5: return (sx < 2 || sx >= 22 || sy < 2 || sy >= 30);
      
      // Número 6: Patrón de tablero
      6: return ((sx[2] ^ sy[2]) == 1'b1);
      
      // Número 7: Diagonales (X)
      7: return ((sx >= sy-2 && sx <= sy+2) || (sx >= (31-sy-2) && sx <= (31-sy+2)));
      
      default: return 1'b0;
    endcase
  endfunction
  
  always_comb begin
    // Fondo negro por defecto
    r = 8'h00; g = 8'h00; b = 8'h00;
    
    // Dibuja las cartas (prioridad: última carta que coincida)
    for (int k = 0; k < 16; k++) begin
      if (incard[k]) begin
        // Calcula posición relativa dentro de la carta
        automatic logic [9:0] card_x, card_y;
        card_x = x - (10'd40 + (k%4) * 10'd160);
        card_y = y - (10'd30 + (k/4) * 10'd120);
        
        // Borde de carta (3 píxeles del borde)
        if (card_x < 3 || card_x >= 77 || card_y < 3 || card_y >= 57) begin
          r = 8'h80; g = 8'h80; b = 8'h80;  // Borde gris
        end else if (symbol_pixel[k]) begin
          r = 8'h00; g = 8'h00; b = 8'h00;  // Símbolo negro
        end else begin
          r = 8'hFF; g = 8'hFF; b = 8'hFF;  // Fondo blanco
        end
      end
    end
  end
  
`else
  // --- MODO_B: Cartas con caracteres desde ROM ---
  logic [15:0] incard;
  logic [15:0] char_pixel;
  
  // Grid 4x4 de cartas
  genvar i, j;
  generate
    for (i = 0; i < 4; i++) begin : row
      for (j = 0; j < 4; j++) begin : col
        localparam logic [9:0] LEFT   = 10'd40  + j * 10'd160;
        localparam logic [9:0] TOP    = 10'd30  + i * 10'd120;
        localparam logic [9:0] RIGHT  = LEFT + 10'd80;
        localparam logic [9:0] BOTTOM = TOP  + 10'd60;
        localparam int CARD_ID = i*4 + j;
        
        rectgen u_card(
          .x(x), .y(y),
          .left(LEFT), .top(TOP), .right(RIGHT), .bot(BOTTOM),
          .inrect(incard[CARD_ID])
        );
      end
    end
  endgenerate
  
  // Calcula píxeles de caracteres para todas las cartas
  always_comb begin
    for (int k = 0; k < 16; k++) begin
      automatic logic [9:0] LEFT_k   = 10'd40 + (k%4) * 10'd160;
      automatic logic [9:0] TOP_k    = 10'd30 + (k/4) * 10'd120;
      automatic logic [9:0] card_x_k = x - LEFT_k;
      automatic logic [9:0] card_y_k = y - TOP_k;
      automatic logic [7:0] char_k   = 8'd48 + (k/2);
      
      char_pixel[k] = get_char_pixel(card_x_k, card_y_k, char_k);
    end
  end
  
  // Función para obtener píxel del carácter desde ROM
  function automatic logic get_char_pixel(
    input logic [9:0] cx,
    input logic [9:0] cy,
    input logic [7:0] ch
  );
    logic [9:0] char_sx, char_sy;
    logic in_char_area;
    logic [2:0] xoff, yoff;
    logic [7:0] line;
    
    in_char_area = (cx >= 28) && (cx < 52) && (cy >= 18) && (cy < 42);
    if (!in_char_area) return 1'b0;
    
    char_sx = cx - 10'd28;
    char_sy = cy - 10'd18;
    
    if (char_sx >= 24 || char_sy >= 24) return 1'b0;
    
    xoff = char_sx[4:2];
    yoff = char_sy[4:2];
    
    line = charrom[{ch, 3'b000} + yoff];
    return line[3'd7 - xoff];
  endfunction
  
  // ROM de caracteres (debe estar en el módulo para acceso desde función)
  logic [7:0] charrom [0:2047];
  initial $readmemb("charrom.txt", charrom);
  
  always_comb begin
    // Fondo negro por defecto
    r = 8'h00; g = 8'h00; b = 8'h00;
    
    // Dibuja las cartas
    for (int k = 0; k < 16; k++) begin
      if (incard[k]) begin
        automatic logic [9:0] card_x, card_y;
        card_x = x - (10'd40 + (k%4) * 10'd160);
        card_y = y - (10'd30 + (k/4) * 10'd120);
        
        if (card_x < 3 || card_x >= 77 || card_y < 3 || card_y >= 57) begin
          r = 8'h80; g = 8'h80; b = 8'h80;  // Borde gris
        end else if (char_pixel[k]) begin
          r = 8'h00; g = 8'h00; b = 8'h00;  // Carácter negro
        end else begin
          r = 8'hFF; g = 8'hFF; b = 8'hFF;  // Fondo blanco
        end
      end
    end
  end
`endif
endmodule

// --- Rectángulo ---
module rectgen(
  input  logic [9:0] x, y,
  input  logic [9:0] left, top, right, bot,
  output logic       inrect
);
  always_comb begin
    inrect = (x >= left) && (x < right) && (y >= top) && (y < bot);
  end
endmodule

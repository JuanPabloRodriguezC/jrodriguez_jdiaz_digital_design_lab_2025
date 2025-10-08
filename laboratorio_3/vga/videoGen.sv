// videoGen.sv — Genera cartas de memoria con cursor (OPTIMIZADO)
module videoGen(
  input  logic [9:0] x,
  input  logic [9:0] y,
  input  logic [3:0] cursor_pos,  // Posición del cursor (0-15)
  output logic [7:0] r,
  output logic [7:0] g,
  output logic [7:0] b
);

  // Detectar si estamos dentro de cada carta
  logic [15:0] incard;
  logic [15:0] cursor_border;  // Borde resaltado del cursor
  
  // Variables para la carta actual
  logic [9:0] card_x, card_y;
  logic [3:0] current_card;
  logic [2:0] symbol_id;
  logic symbol_pixel;
  
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
        
        rectGen u_card(
          .x(x), .y(y),
          .left(LEFT), .top(TOP), .right(RIGHT), .bot(BOTTOM),
          .inrect(incard[CARD_ID])
        );
        
        // Detectar borde extendido para cursor (5 píxeles extra)
        rectGen u_cursor(
          .x(x), .y(y),
          .left(LEFT - 10'd5), .top(TOP - 10'd5), 
          .right(RIGHT + 10'd5), .bot(BOTTOM + 10'd5),
          .inrect(cursor_border[CARD_ID])
        );
      end
    end
  endgenerate
  
  // Determinar carta actual y coordenadas relativas
  always_comb begin
    current_card = 4'd0;
    card_x = 10'd0;
    card_y = 10'd0;
    
    for (int k = 0; k < 16; k++) begin
      if (incard[k]) begin
        current_card = k[3:0];
        card_x = x - (10'd40 + (k%4) * 10'd160);
        card_y = y - (10'd30 + (k/4) * 10'd120);
      end
    end
    
    symbol_id = current_card[3:1];  // 8 símbolos (0-7)
  end
  
  // Generador de símbolos simplificado
  always_comb begin
    symbol_pixel = 1'b0;
    
    // Área de símbolo: centro de la carta
    if (card_x >= 26 && card_x < 54 && card_y >= 14 && card_y < 46) begin
      automatic logic [9:0] sx = card_x - 10'd26;
      automatic logic [9:0] sy = card_y - 10'd14;
      
      case (symbol_id)
        // Símbolo 0: Círculo simple
        3'd0: symbol_pixel = ((sx-14)*(sx-14) + (sy-16)*(sy-16)) < 100;
        
        // Símbolo 1: Cuadrado
        3'd1: symbol_pixel = (sx >= 6 && sx < 22 && sy >= 8 && sy < 24);
        
        // Símbolo 2: Cruz
        3'd2: symbol_pixel = ((sx >= 12 && sx < 16) || (sy >= 14 && sy < 18));
        
        // Símbolo 3: Triángulo
        3'd3: symbol_pixel = (sy >= 8 && sx >= (14-sy/2) && sx < (14+sy/2));
        
        // Símbolo 4: Diamante
        3'd4: begin
          if (sy < 16)
            symbol_pixel = (sx >= (14-sy) && sx < (14+sy));
          else
            symbol_pixel = (sx >= (sy-16) && sx < (46-sy));
        end
        
        // Símbolo 5: X
        3'd5: symbol_pixel = ((sx == sy) || (sx == (31-sy)));
        
        // Símbolo 6: Estrella simple (5 líneas)
        3'd6: begin
          symbol_pixel = (sx >= 12 && sx < 16) ||  // Vertical
                        (sy >= 14 && sy < 18) ||   // Horizontal
                        ((sx-sy) == 2) ||          // Diagonal 1
                        ((sx+sy) == 30);           // Diagonal 2
        end
        
        // Símbolo 7: Corazón simplificado
        3'd7: begin
          if (sy < 12)
            symbol_pixel = ((sx-8)*(sx-8) + (sy-6)*(sy-6) < 36) || 
                          ((sx-20)*(sx-20) + (sy-6)*(sy-6) < 36);
          else
            symbol_pixel = (sx >= (14-sy/2) && sx < (14+sy/2));
        end
        
        default: symbol_pixel = 1'b0;
      endcase
    end
  end
  
  // Dibuja las cartas con símbolos y cursor
  always_comb begin
    // Fondo verde oscuro (como mesa de póker)
    r = 8'h00; g = 8'h40; b = 8'h00;
    
    // Primero dibuja el cursor si estamos en su borde
    if (cursor_border[cursor_pos] && !incard[cursor_pos]) begin
      // Borde del cursor: cian brillante
      r = 8'h00; g = 8'hFF; b = 8'hFF;
    end
    
    // Dibuja la carta activa
    if (|incard) begin  // Si alguna carta está activa
      // Si es la carta con el cursor, usar borde cian
      if (current_card == cursor_pos) begin
        if (card_x < 5 || card_x >= 75 || card_y < 5 || card_y >= 55) begin
          r = 8'h00; g = 8'hFF; b = 8'hFF;  // Cian brillante
        end else if (symbol_pixel) begin
          // Color del símbolo según ID
          case (symbol_id)
            3'd0: begin r = 8'hFF; g = 8'h00; b = 8'h00; end // Rojo
            3'd1: begin r = 8'h00; g = 8'h00; b = 8'hFF; end // Azul
            3'd2: begin r = 8'h00; g = 8'hFF; b = 8'h00; end // Verde
            3'd3: begin r = 8'hFF; g = 8'hFF; b = 8'h00; end // Amarillo
            3'd4: begin r = 8'hFF; g = 8'h00; b = 8'hFF; end // Magenta
            3'd5: begin r = 8'h00; g = 8'hFF; b = 8'hFF; end // Cian
            3'd6: begin r = 8'hFF; g = 8'hA5; b = 8'h00; end // Naranja
            3'd7: begin r = 8'h80; g = 8'h00; b = 8'h80; end // Púrpura
            default: begin r = 8'hFF; g = 8'hFF; b = 8'hFF; end
          endcase
        end else begin
          // Fondo de carta: blanco cremoso
          r = 8'hFF; g = 8'hF8; b = 8'hE8;
        end
      end else begin
        // Cartas normales con borde dorado
        if (card_x < 3 || card_x >= 77 || card_y < 3 || card_y >= 57) begin
          r = 8'hD4; g = 8'hAF; b = 8'h37;  // Dorado
        end else if (symbol_pixel) begin
          // Color del símbolo según ID
          case (symbol_id)
            3'd0: begin r = 8'hFF; g = 8'h00; b = 8'h00; end // Rojo
            3'd1: begin r = 8'h00; g = 8'h00; b = 8'hFF; end // Azul
            3'd2: begin r = 8'h00; g = 8'hFF; b = 8'h00; end // Verde
            3'd3: begin r = 8'hFF; g = 8'hFF; b = 8'h00; end // Amarillo
            3'd4: begin r = 8'hFF; g = 8'h00; b = 8'hFF; end // Magenta
            3'd5: begin r = 8'h00; g = 8'hFF; b = 8'hFF; end // Cian
            3'd6: begin r = 8'hFF; g = 8'hA5; b = 8'h00; end // Naranja
            3'd7: begin r = 8'h80; g = 8'h00; b = 8'h80; end // Púrpura
            default: begin r = 8'hFF; g = 8'hFF; b = 8'hFF; end
          endcase
        end else begin
          // Fondo de carta: blanco cremoso
          r = 8'hFF; g = 8'hF8; b = 8'hE8;
        end
      end
    end
  end
endmodule

// --- Rectángulo ---
module rectGen(
  input  logic [9:0] x, y,
  input  logic [9:0] left, top, right, bot,
  output logic       inrect
);
  always_comb begin
    inrect = (x >= left) && (x < right) && (y >= top) && (y < bot);
  end
endmodule
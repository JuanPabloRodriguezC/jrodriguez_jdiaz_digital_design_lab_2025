// videoGen.sv — Genera cartas de memoria con cursor
// Las cartas están volteadas (blancas) por defecto
// Muestra símbolo basado en el valor de la carta, no su posición
// El color del cursor cambia según el turno (Cian=P1, Amarillo=P2)
module videoGen(
  input  logic [9:0]  x,
  input  logic [9:0]  y,
  input  logic [3:0]  cursor_pos,
  input  logic [15:0] cards_face_up,  // Bit en 1 = carta boca arriba
  input  logic        turno,          // 0=Jugador1, 1=Jugador2
  output logic [7:0]  r,
  output logic [7:0]  g,
  output logic [7:0]  b
);

  logic [15:0] incard;
  logic [15:0] cursor_border;
  
  logic [9:0] card_x, card_y;
  logic [3:0] current_card;
  logic [2:0] symbol_id;
  logic symbol_pixel;
  logic is_face_up;
  
  // Colores del cursor según el turno
  logic [7:0] cursor_r, cursor_g, cursor_b;
  
  // Tabla de valores de cartas (debe coincidir con FSM)
  logic [2:0] card_values [0:15];
  
  initial begin
    card_values[0]  = 3'd0;  card_values[1]  = 3'd0;
    card_values[2]  = 3'd1;  card_values[3]  = 3'd1;
    card_values[4]  = 3'd2;  card_values[5]  = 3'd2;
    card_values[6]  = 3'd3;  card_values[7]  = 3'd3;
    card_values[8]  = 3'd4;  card_values[9]  = 3'd4;
    card_values[10] = 3'd5;  card_values[11] = 3'd5;
    card_values[12] = 3'd6;  card_values[13] = 3'd6;
    card_values[14] = 3'd7;  card_values[15] = 3'd7;
  end
  
  // Asignar color del cursor según el turno
  always_comb begin
    if (turno == 1'b0) begin
      // Jugador 1: Cian
      cursor_r = 8'h00;
      cursor_g = 8'hFF;
      cursor_b = 8'hFF;
    end else begin
      // Jugador 2: Amarillo
      cursor_r = 8'hFF;
      cursor_g = 8'hFF;
      cursor_b = 8'h00;
    end
  end
  
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
        
        rectGen u_cursor(
          .x(x), .y(y),
          .left(LEFT - 10'd5), .top(TOP - 10'd5), 
          .right(RIGHT + 10'd5), .bot(BOTTOM + 10'd5),
          .inrect(cursor_border[CARD_ID])
        );
      end
    end
  endgenerate
  
  // Determinar carta actual y su valor
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
    
    // Usar el valor de la carta, no su posición
    symbol_id = card_values[current_card];
    is_face_up = cards_face_up[current_card];
  end
  
  // Generador de símbolos
  always_comb begin
    symbol_pixel = 1'b0;
    
    if (card_x >= 26 && card_x < 54 && card_y >= 14 && card_y < 46) begin
      automatic logic [9:0] sx = card_x - 10'd26;
      automatic logic [9:0] sy = card_y - 10'd14;
      
      case (symbol_id)
        3'd0: symbol_pixel = ((sx-14)*(sx-14) + (sy-16)*(sy-16)) < 100;
        3'd1: symbol_pixel = (sx >= 6 && sx < 22 && sy >= 8 && sy < 24);
        3'd2: symbol_pixel = ((sx >= 12 && sx < 16) || (sy >= 14 && sy < 18));
        3'd3: symbol_pixel = (sy >= 8 && sx >= (14-sy/2) && sx < (14+sy/2));
        3'd4: begin
          if (sy < 16)
            symbol_pixel = (sx >= (14-sy) && sx < (14+sy));
          else
            symbol_pixel = (sx >= (sy-16) && sx < (46-sy));
        end
        3'd5: symbol_pixel = ((sx == sy) || (sx == (31-sy)));
        3'd6: begin
          symbol_pixel = (sx >= 12 && sx < 16) || (sy >= 14 && sy < 18) ||
                        ((sx-sy) == 2) || ((sx+sy) == 30);
        end
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
  
  // Renderizado
  always_comb begin
    r = 8'h00; g = 8'h40; b = 8'h00;  // Fondo verde
    
    // Borde del cursor (fuera de la carta) - usa color según turno
    if (cursor_border[cursor_pos] && !incard[cursor_pos]) begin
      r = cursor_r;
      g = cursor_g;
      b = cursor_b;
    end
    
    if (|incard) begin
      if (current_card == cursor_pos) begin
        // Carta con cursor - borde usa color según turno
        if (card_x < 5 || card_x >= 75 || card_y < 5 || card_y >= 55) begin
          r = cursor_r;
          g = cursor_g;
          b = cursor_b;
        end else if (is_face_up && symbol_pixel) begin
          // Mostrar símbolo solo si está boca arriba
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
          // Fondo blanco (carta boca abajo)
          r = 8'hFF; g = 8'hFF; b = 8'hFF;
        end
      end else begin
        // Cartas sin cursor - borde dorado
        if (card_x < 3 || card_x >= 77 || card_y < 3 || card_y >= 57) begin
          r = 8'hD4; g = 8'hAF; b = 8'h37;
        end else if (is_face_up && symbol_pixel) begin
          case (symbol_id)
            3'd0: begin r = 8'hFF; g = 8'h00; b = 8'h00; end
            3'd1: begin r = 8'h00; g = 8'h00; b = 8'hFF; end
            3'd2: begin r = 8'h00; g = 8'hFF; b = 8'h00; end
            3'd3: begin r = 8'hFF; g = 8'hFF; b = 8'h00; end
            3'd4: begin r = 8'hFF; g = 8'h00; b = 8'hFF; end
            3'd5: begin r = 8'h00; g = 8'hFF; b = 8'hFF; end
            3'd6: begin r = 8'hFF; g = 8'hA5; b = 8'h00; end
            3'd7: begin r = 8'h80; g = 8'h00; b = 8'h80; end
            default: begin r = 8'hFF; g = 8'hFF; b = 8'hFF; end
          endcase
        end else begin
          r = 8'hFF; g = 8'hFF; b = 8'hFF;
        end
      end
    end
  end
endmodule

module rectGen(
  input  logic [9:0] x, y,
  input  logic [9:0] left, top, right, bot,
  output logic       inrect
);
  always_comb begin
    inrect = (x >= left) && (x < right) && (y >= top) && (y < bot);
  end
endmodule
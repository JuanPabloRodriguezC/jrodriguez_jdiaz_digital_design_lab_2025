// videoGen.sv — Genera cartas de memoria con cursor de navegación
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
  logic [15:0] symbol_pixel;
  logic [15:0] cursor_border;  // Borde resaltado del cursor
  
  // Grid 4x4 de cartas: 640x480 -> cada celda ~160x120
  // Cartas de 80x60, centradas en cada celda
  // Espaciado: 160 horizontal, 120 vertical
  // Inicio: (40, 30)
  
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
        
        // Detectar borde extendido para cursor (5 píxeles extra)
        rectgen u_cursor(
          .x(x), .y(y),
          .left(LEFT - 10'd5), .top(TOP - 10'd5), 
          .right(RIGHT + 10'd5), .bot(BOTTOM + 10'd5),
          .inrect(cursor_border[CARD_ID])
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
      automatic int symbol_id = k / 2;  // 8 pares de símbolos
      
      symbol_pixel[k] = get_symbol_pixel(card_x_k, card_y_k, symbol_id);
    end
  end
  
  // Función para generar píxeles de símbolos de cartas
  function automatic logic get_symbol_pixel(
    input logic [9:0] cx,
    input logic [9:0] cy,
    input int sid
  );
    logic [9:0] sx, sy;
    logic in_area;
    logic pixel;
    
    // Área central para el símbolo: 28x32 píxeles
    sx = cx - 10'd26;
    sy = cy - 10'd14;
    in_area = (cx >= 26) && (cx < 54) && (cy >= 14) && (cy < 46);
    
    if (!in_area) return 1'b0;
    
    case (sid)
      // Símbolo 0: CORAZÓN ♥
      0: begin
        // Dos círculos arriba + triángulo abajo
        logic left_circle, right_circle, triangle;
        left_circle = ((sx-7)*(sx-7) + (sy-8)*(sy-8)) < 49;  // r²=49
        right_circle = ((sx-21)*(sx-21) + (sy-8)*(sy-8)) < 49;
        triangle = (sy >= 8) && (sx >= (14 - sy/2)) && (sx < (14 + sy/2));
        pixel = left_circle || right_circle || triangle;
        return pixel;
      end
      
      // Símbolo 1: DIAMANTE ♦
      1: begin
        // Rombo centrado
        logic upper, lower;
        upper = (sy < 16) && (sx >= (14-sy)) && (sx < (14+sy));
        lower = (sy >= 16) && (sx >= (sy-16)) && (sx < (46-sy));
        return upper || lower;
      end
      
      // Símbolo 2: TRÉBOL ♣
      2: begin
        // Tres círculos + tallo
        logic top_circle, left_circle, right_circle, stem;
        top_circle = ((sx-14)*(sx-14) + (sy-6)*(sy-6)) < 36;
        left_circle = ((sx-8)*(sx-8) + (sy-14)*(sy-14)) < 36;
        right_circle = ((sx-20)*(sx-20) + (sy-14)*(sy-14)) < 36;
        stem = (sx >= 12) && (sx < 16) && (sy >= 18) && (sy < 28);
        return top_circle || left_circle || right_circle || stem;
      end
      
      // Símbolo 3: PICA ♠
      3: begin
        // Corazón invertido + tallo
        logic triangle, left_curve, right_curve, stem;
        triangle = (sy < 16) && (sx >= (14-sy/2)) && (sx < (14+sy/2));
        left_curve = ((sx-7)*(sx-7) + (sy-20)*(sy-20)) < 36;
        right_curve = ((sx-21)*(sx-21) + (sy-20)*(sy-20)) < 36;
        stem = (sx >= 12) && (sx < 16) && (sy >= 22) && (sy < 30);
        return triangle || left_curve || right_curve || stem;
      end
      
      // Símbolo 4: ESTRELLA ★
      4: begin
        // Estrella de 5 puntas simplificada
        logic center, p1, p2, p3, p4, p5;
        center = ((sx-14)*(sx-14) + (sy-16)*(sy-16)) < 25;
        // Puntas
        p1 = (sy < 8) && (sx >= 12) && (sx < 16);  // Arriba
        p2 = (sy >= 8) && (sy < 16) && (sx < 8) && (sx >= 4);  // Izq-arr
        p3 = (sy >= 16) && (sy < 24) && (sx < 6) && (sx >= 2);  // Izq-abajo
        p4 = (sy >= 8) && (sy < 16) && (sx >= 20) && (sx < 24);  // Der-arr
        p5 = (sy >= 16) && (sy < 24) && (sx >= 22) && (sx < 26);  // Der-abajo
        return center || p1 || p2 || p3 || p4 || p5;
      end
      
      // Símbolo 5: CÍRCULO ●
      5: begin
        return ((sx-14)*(sx-14) + (sy-16)*(sy-16)) < 100;
      end
      
      // Símbolo 6: CUADRADO ■
      6: begin
        return (sx >= 6) && (sx < 22) && (sy >= 8) && (sy < 24);
      end
      
      // Símbolo 7: PIKACHU
      7: begin
        // Pikachu pixelado estilo 16x16
        logic pixel;
        pixel = 1'b0;
        
        // Cabeza redonda (óvalo)
        if ((sy >= 10 && sy < 26) && (sx >= 6 && sx < 22)) begin
          if ((sy == 10 || sy == 25) && (sx >= 9 && sx < 19)) pixel = 1'b1;
          else if ((sy >= 11 && sy < 25) && (sx >= 6 && sx < 22)) pixel = 1'b1;
        end
        
        // Orejas (triángulos largos)
        // Oreja izquierda
        if ((sy >= 2 && sy < 10) && (sx >= 6 && sx < 10)) begin
          if (sx >= (8 - sy/3) && sx < (10 - sy/5)) pixel = 1'b1;
        end
        // Oreja derecha
        if ((sy >= 2 && sy < 10) && (sx >= 18 && sx < 22)) begin
          if (sx >= (18 + sy/5) && sx < (20 + sy/3)) pixel = 1'b1;
        end
        
        // Puntas negras de orejas
        if ((sy >= 2 && sy < 5) && ((sx >= 7 && sx < 9) || (sx >= 19 && sx < 21))) begin
          pixel = 1'b0;  // Se colorearán de negro después
        end
        
        // Ojos (dos círculos negros)
        if ((sy >= 14 && sy < 17) && ((sx >= 10 && sx < 12) || (sx >= 16 && sx < 18))) begin
          pixel = 1'b0;  // Negro
        end
        
        // Nariz pequeña
        if ((sy >= 18 && sy < 19) && (sx >= 13 && sx < 15)) pixel = 1'b0;
        
        // Boca (sonrisa)
        if (sy == 20 && ((sx >= 11 && sx < 13) || (sx >= 15 && sx < 17))) pixel = 1'b0;
        
        return pixel;
      end
      
      default: return 1'b0;
    endcase
  endfunction
  
  // Dibuja las cartas con símbolos y cursor
  always_comb begin
    // Fondo verde oscuro (como mesa de póker)
    r = 8'h00; g = 8'h40; b = 8'h00;
    
    // Primero dibuja el cursor si estamos en su borde
    if (cursor_border[cursor_pos] && !incard[cursor_pos]) begin
      // Borde del cursor: cian brillante
      r = 8'h00; g = 8'hFF; b = 8'hFF;
    end
    
    // Dibuja las cartas sobre el cursor
    for (int k = 0; k < 16; k++) begin
      if (incard[k]) begin
        automatic logic [9:0] card_x, card_y;
        automatic int symbol_id;
        
        card_x = x - (10'd40 + (k%4) * 10'd160);
        card_y = y - (10'd30 + (k/4) * 10'd120);
        symbol_id = k / 2;
        
        // Si es la carta con el cursor, usar borde cian más grueso
        if (k == cursor_pos) begin
          // Borde de carta seleccionada (5 píxeles) - CIAN
          if (card_x < 5 || card_x >= 75 || card_y < 5 || card_y >= 55) begin
            r = 8'h00; g = 8'hFF; b = 8'hFF;  // Cian brillante
          end else if (symbol_pixel[k]) begin
            // Color del símbolo según tipo
            case (symbol_id)
              0: begin r = 8'hFF; g = 8'h00; b = 8'h00; end // Corazón ROJO
              1: begin r = 8'hFF; g = 8'h00; b = 8'h00; end // Diamante ROJO
              2: begin r = 8'h00; g = 8'h00; b = 8'h00; end // Trébol NEGRO
              3: begin r = 8'h00; g = 8'h00; b = 8'h00; end // Pica NEGRO
              4: begin r = 8'hFF; g = 8'hD7; b = 8'h00; end // Estrella DORADA
              5: begin r = 8'h00; g = 8'h00; b = 8'hFF; end // Círculo AZUL
              6: begin r = 8'h80; g = 8'h00; b = 8'h80; end // Cuadrado PÚRPURA
              7: begin r = 8'hFF; g = 8'hCC; b = 8'h00; end // Pikachu AMARILLO
              default: begin r = 8'h00; g = 8'h00; b = 8'h00; end
            endcase
          end else begin
            // Fondo de carta: blanco cremoso
            r = 8'hFF; g = 8'hF8; b = 8'hE8;
          end
        end else begin
          // Cartas normales con borde dorado
          if (card_x < 3 || card_x >= 77 || card_y < 3 || card_y >= 57) begin
            r = 8'hD4; g = 8'hAF; b = 8'h37;  // Dorado
          end else if (symbol_pixel[k]) begin
            // Color del símbolo según tipo
            case (symbol_id)
              0: begin r = 8'hFF; g = 8'h00; b = 8'h00; end // Corazón ROJO
              1: begin r = 8'hFF; g = 8'h00; b = 8'h00; end // Diamante ROJO
              2: begin r = 8'h00; g = 8'h00; b = 8'h00; end // Trébol NEGRO
              3: begin r = 8'h00; g = 8'h00; b = 8'h00; end // Pica NEGRO
              4: begin r = 8'hFF; g = 8'hD7; b = 8'h00; end // Estrella DORADA
              5: begin r = 8'h00; g = 8'h00; b = 8'hFF; end // Círculo AZUL
              6: begin r = 8'h80; g = 8'h00; b = 8'h80; end // Cuadrado PÚRPURA
              7: begin r = 8'hFF; g = 8'hCC; b = 8'h00; end // Pikachu AMARILLO
              default: begin r = 8'h00; g = 8'h00; b = 8'h00; end
            endcase
          end else begin
            // Fondo de carta: blanco cremoso
            r = 8'hFF; g = 8'hF8; b = 8'hE8;
          end
        end
      end
    end
  end
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
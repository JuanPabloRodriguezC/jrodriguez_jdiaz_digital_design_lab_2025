module videoGen(
    input  logic [9:0] x, y,
	 input  logic blank_b,
    output logic [7:0] r, g, b
);

    // Parámetros del tablero
    localparam CARD_W = 80;   // ancho de cada carta
    localparam CARD_H = 100;  // alto de cada carta
    localparam GAP    = 20;   // separación entre cartas
    localparam OFFSET_X = 60; // margen desde izquierda
    localparam OFFSET_Y = 40; // margen desde arriba

    // Cursor fijo (posición [0][0])
    localparam CURSOR_X = OFFSET_X;
    localparam CURSOR_Y = OFFSET_Y;

    logic in_card;
    logic in_cursor;
    integer row, col;
    integer left, top, right, bot;

    always_comb begin
        // Fondo negro por defecto
        {r,g,b} = 24'h000000;

        in_card   = 0;
        in_cursor = 0;

        // Revisar cada carta del tablero 4x4
        for (row = 0; row < 4; row++) begin
            for (col = 0; col < 4; col++) begin
                left  = OFFSET_X + col * (CARD_W + GAP);
                top   = OFFSET_Y + row * (CARD_H + GAP);
                right = left + CARD_W;
                bot   = top  + CARD_H;

                if (x >= left && x < right && y >= top && y < bot) begin
                    in_card = 1;
                end
            end
        end

        // Dibujar cursor en la carta [0][0]
        if (x >= CURSOR_X-2 && x < CURSOR_X+CARD_W+2 &&
            y >= CURSOR_Y-2 && y < CURSOR_Y+CARD_H+2)
            in_cursor = 1;

        // Colores
        if (in_card) begin
            {r,g,b} = 24'h808080; // gris carta
        end
        if (in_cursor) begin
            {r,g,b} = 24'hFFFF00; // borde amarillo
        end
    end

endmodule
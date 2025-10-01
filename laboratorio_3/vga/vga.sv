module vga(
    input  logic clk,                     // Reloj de FPGA (ej. 50 MHz)
    output logic vgaclk,                  // Pixel clock 25.175 MHz
	 input  logic rst_n,
    output logic hsync, vsync,
    output logic sync_b, blank_b,
    output logic [7:0] r, g, b            // Señales de color
);

    logic [9:0] x, y;

    // Generar pixel clock con PLL
    pll vgapll(.inclk0(clk), .c0(vgaclk), .rst_n(rst_n));

    // Controlador VGA: genera hsync, vsync, x, y
    vgaController vgaCont(
        .vgaclk(vgaclk),
        .hsync(hsync),
        .vsync(vsync),
        .sync_b(sync_b),
        .blank_b(blank_b),
        .x(x),
        .y(y)
    );

    // Generador de video (tablero 4x4 + cursor)
    videoGen videoGen(
        .x(x), .y(y),
        .r(r), .g(g), .b(b),
		  .blank_b(blank_b)
    );

endmodule

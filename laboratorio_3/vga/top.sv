module top (
    input  logic CLOCK_50,        // Reloj de 50 MHz de la DE10-Standard
    output logic [3:0] VGA_R,     // Salida VGA rojo
    output logic [3:0] VGA_G,     // Salida VGA verde
    output logic [3:0] VGA_B,     // Salida VGA azul
    output logic VGA_HS,          // Señal HSync
    output logic VGA_VS           // Señal VSync
);

    // Señales internas
    logic        vga_clk;   // Pixel clock (25 MHz aprox)
    logic        hsync, vsync, sync_b, blank_b;
    logic [7:0]  r, g, b;

    // Instancia del módulo VGA principal
    vga vga_inst (
        .clk(CLOCK_50),
        .vgaclk(vga_clk),
        .hsync(hsync),
        .vsync(vsync),
        .sync_b(sync_b),
        .blank_b(blank_b),
        .r(r),
        .g(g),
        .b(b)
    );

    // Asignación de pines de salida VGA (recorte a 4 bits)
    assign VGA_R = r[7:4];
    assign VGA_G = g[7:4];
    assign VGA_B = b[7:4];

    assign VGA_HS = hsync;
    assign VGA_VS = vsync;

endmodule

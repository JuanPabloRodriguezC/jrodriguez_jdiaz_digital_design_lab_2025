module pll(
    input  logic inclk0,   // Reloj de entrada (50 MHz)
    output logic c0        // Reloj de salida (25 MHz)
);
    vga_pll pll_inst (
        .inclk0(inclk0),   // Conectamos CLOCK_50
        .c0(c0)            // Sale vgaclk para el VGA
    );
endmodule
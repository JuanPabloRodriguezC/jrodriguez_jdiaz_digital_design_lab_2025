module pll(
    input  logic inclk0,   // Reloj de entrada (50 MHz)
	 input  logic rst_n,
    output logic c0,        // Reloj de salida (25 MHz)
	 output logic locked
);
    
    vga_pll pll_inst (
        .refclk(inclk0),   // Conectamos CLOCK_50
        .rst(~rst_n),        // Reset en bajo (sin reset)
        .outclk_0(c0),     // Sale vgaclk para el VGA
        .locked(locked)    // Estado de bloqueo (opcional monitorearlo)
    );
endmodule
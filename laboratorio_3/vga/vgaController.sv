module vgaController #(
    parameter HACTIVE = 10'd640,
              HFP     = 10'd16,
              HSYN    = 10'd96,
              HBP     = 10'd48,
              HMAX    = HACTIVE + HFP + HSYN + HBP, // 800
              VACTIVE = 10'd480,
              VFP     = 10'd10,
              VSYN    = 10'd2,
              VBP     = 10'd33,
              VMAX    = VACTIVE + VFP + VSYN + VBP  // 525
)(
    input  logic vgaclk,
    output logic hsync, vsync,
    output logic sync_b, blank_b,
    output logic [9:0] x, y
);
    logic [9:0] hcnt;
    logic [9:0] vcnt;
    
    // Contador horizontal
    always_ff @(posedge vgaclk) begin
        if (hcnt >= HMAX - 1) begin
            hcnt <= 10'd0;
            // Incrementar contador vertical al final de cada línea
            if (vcnt >= VMAX - 1)
                vcnt <= 10'd0;
            else
                vcnt <= vcnt + 10'd1;
        end else begin
            hcnt <= hcnt + 10'd1;
        end
    end
    
    // Asignar coordenadas x, y
    assign x = hcnt;
    assign y = vcnt;
    
    // Generar señales de sincronización (activas en BAJO para VGA estándar)
    assign hsync = ~((hcnt >= (HACTIVE + HFP)) && 
                     (hcnt < (HACTIVE + HFP + HSYN)));
    
    assign vsync = ~((vcnt >= (VACTIVE + VFP)) && 
                     (vcnt < (VACTIVE + VFP + VSYN)));
    
    assign sync_b = hsync & vsync;
    
    // Área visible (blank_b es alto durante el área activa)
    assign blank_b = (hcnt < HACTIVE) && (vcnt < VACTIVE);
    
endmodule
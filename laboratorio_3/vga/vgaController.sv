module vgaController #(
    parameter HACTIVE = 10'd640,
              HFP     = 10'd16,
              HSYN    = 10'd96,
              HBP     = 10'd48,
              HMAX    = HACTIVE + HFP + HSYN + HBP,
              VACTIVE = 10'd480,
              VFP     = 10'd11,
              VSYN    = 10'd2,
              VBP     = 10'd32,
              VMAX    = VACTIVE + VFP + VSYN + VBP
)(
    input  logic vgaclk,
    output logic hsync, vsync,
    output logic sync_b, blank_b,
    output logic [9:0] x, y
);

    logic [9:0] hcnt = 0;
    logic [9:0] vcnt = 0;

    always_ff @(posedge vgaclk) begin
        if (hcnt == HMAX-1) begin
            hcnt <= 0;
            if (vcnt == VMAX-1)
                vcnt <= 0;
            else
                vcnt <= vcnt + 1;
        end else begin
            hcnt <= hcnt + 1;
        end
    end

    assign x = hcnt;
    assign y = vcnt;

    // Señales de sincronización (activas en bajo)
    assign hsync   = ~(hcnt >= HACTIVE + HFP && hcnt < HACTIVE + HFP + HSYN);
    assign vsync   = ~(vcnt >= VACTIVE + VFP && vcnt < VACTIVE + VFP + VSYN);
    assign sync_b  = hsync & vsync;

    // Área visible
    assign blank_b = (hcnt < HACTIVE) && (vcnt < VACTIVE);

endmodule

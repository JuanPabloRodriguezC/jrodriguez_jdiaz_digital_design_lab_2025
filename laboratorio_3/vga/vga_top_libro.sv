module vga_top_libro(
  input  logic        clk,          // clock de placa (50 MHz)
  input  logic        rst_n,        // reset activo en bajo
  output logic        hsync,
  output logic        vsync,
  output logic        vga_clk,
  output logic        vga_blank_n,
  output logic        vga_sync_n,
  output logic [7:0]  vga_r,
  output logic [7:0]  vga_g,
  output logic [7:0]  vga_b,
  output logic [6:0]  seg_units,    // 7-segment units
  output logic [6:0]  seg_tens      // 7-segment tens
);

  // ===== 1) Pixel clock =====
  logic vgaclk;

`ifdef USE_PLL
  pll vgapll(.inclk0(clk), .c0(vgaclk));
`else
  gen_pixclk #(
    .SYS_CLK_HZ(50_000_000),
    .PIX_CLK_HZ(25_000_000)
  ) u_pix (
    .clk    (clk),
    .rst    (~rst_n),
    .clk_pix(vgaclk)
  );
`endif

  assign vga_clk    = vgaclk;
  assign vga_sync_n = 1'b1;

  // ===== 2) VGA Controller =====
  logic [9:0] x, y;
  logic       blank_b;

  vgaController u_ctrl(
    .vgaclk (vgaclk),
    .rst    (~rst_n),
    .hsync  (hsync),
    .vsync  (vsync),
    .sync_b (),
    .blank_b(blank_b),
    .x      (x),
    .y      (y)
  );

  assign vga_blank_n = blank_b;

  // ===== 3) Timer (countdown from 15) =====
  logic [3:0] timer_value;
  logic timer_timeout;
  
  timer #(
    .CLOCK_FREQ(50_000_000)  // Frecuencia utilizada
  ) u_timer (
    .clk(clk),
    .rst(~rst_n),
    .enable(1'b1),           // Always enabled
    .timeout(timer_timeout),
    .segments_units(seg_units),
    .segments_tens(seg_tens),
    .count_value(timer_value)
  );

  // ===== 4) Video Generation , usa Timer Display =====
  videoGen u_vid(
    .x(x),
    .y(y),
    .r(vga_r),
    .g(vga_g),
    .b(vga_b)
  );

endmodule

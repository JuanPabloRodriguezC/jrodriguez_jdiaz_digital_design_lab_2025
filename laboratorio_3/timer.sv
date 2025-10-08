module timer #(
  parameter CLOCK_FREQ = 50_000_000  // 50 MHz clock
)(
  input  logic clk,
  input  logic rst,
  input  logic enable,
  
  output logic timeout,
  output logic [6:0] segments_units,
  output logic [6:0] segments_tens
);

  logic [31:0] counter;
  logic [3:0] seconds;
  logic [3:0] units_digit;
  logic [3:0] tens_digit;
  
  // Counter for 1 second intervals
  always_ff @(posedge clk) begin
    if (rst) begin
      counter <= 0;
      seconds <= 4'd15;  // Start from 15
    end
    else if (enable) begin
      if (seconds == 0) begin
        counter <= counter;  // Stop counting
      end
      else if (counter >= CLOCK_FREQ - 1) begin
        counter <= 0;
        seconds <= seconds - 1;  // Countdown
      end
      else begin
        counter <= counter + 1;
      end
    end
	 end
  endmodule
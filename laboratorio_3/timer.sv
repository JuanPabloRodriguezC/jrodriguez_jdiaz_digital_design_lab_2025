module timer #(
  parameter MAX_COUNT = 750_000_000
)(
  input  logic clk,
  input  logic rst,
  input  logic enable,
  
  output logic timeout,
  output logic [31:0] count_value
);

  logic [31:0] counter;
  
  always_ff @(posedge clk) begin
    if (rst) begin
      counter <= 0;
    end
    else if (enable) begin
      if (counter >= MAX_COUNT - 1) begin
        counter <= counter;
      end
      else begin
        counter <= counter + 1;
      end
    end
  end
  
  assign timeout = (counter >= MAX_COUNT - 1);
  assign count_value = counter;

endmodule
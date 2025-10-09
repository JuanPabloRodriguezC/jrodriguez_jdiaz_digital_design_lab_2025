module timer #(
  parameter MAX_COUNT = 750_000_000
)(
  input  logic clk,
  input  logic rst,
  input  logic enable,
  
  output logic timeout,
  output logic [6:0] segments_units,
  output logic [6:0] segments_tens,
  output logic [31:0] count_value
);

  logic [31:0] counter;
  logic [3:0] units_digit;
  logic [3:0] tens_digit;
  
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

  always_comb begin
        if (count_value < 10) begin
            tens_digit = 4'b0000;
            units_digit = count_value[3:0];
        end else if (count_value < 20) begin
            tens_digit = 4'b0001;
            units_digit = count_value - 10;
        end else if (count_value < 30) begin
            tens_digit = 4'b0010;
            units_digit = count_value - 20;
        end else if (count_value < 40) begin
            tens_digit = 4'b0011;
            units_digit = count_value - 30;
        end else if (count_value < 50) begin
            tens_digit = 4'b0100;
            units_digit = count_value - 40;
        end else if (count_value < 60) begin
            tens_digit = 4'b0101;
            units_digit = count_value - 50;
        end else begin // 60-63 para WIDTH=4
            tens_digit = 4'b0110;
            units_digit = count_value - 60;
        end
    end
    
    // 10. Instanciación de decodificadores de 7 segmentos
    decoder_segmentos display_decenas (
        .data(tens_digit),
        .segments(segments_tens)
    );
    
    decoder_segmentos display_unidades (
        .data(units_digit),
        .segments(segments_units)
    );

endmodule
module problema_3 #(parameter WIDTH=6)(
    input  logic clk,
    input  logic reset_n,
    input  logic button,
    output logic [6:0] segments_units,
    output logic [6:0] segments_tens
);
    logic [WIDTH-1:0] count;
    logic overflow;
    logic button_pulse;
	 logic [3:0] units_digit;
    logic [3:0] tens_digit;
	 

    button_edge debouncer (
        .clk(clk),
        .reset_n(reset_n), 
        .button_in(button),
        .button_pulse(button_pulse)
    );

    // 2. Contador parametrizable
    contador #(.WIDTH(WIDTH)) contador (
        .clk(clk),
        .reset_n(reset_n),
        .enable(button_pulse),
        .count(count),
        .overflow(overflow)
    );
	 //3. Convierte a BCD
	 always_comb begin
        if (count < 10) begin
            tens_digit = 4'b0000;
            units_digit = count[3:0];
        end else if (count < 20) begin
            tens_digit = 4'b0001;
            units_digit = count - 10;
        end else if (count < 30) begin
            tens_digit = 4'b0010;
            units_digit = count - 20;
        end else if (count < 40) begin
            tens_digit = 4'b0011;
            units_digit = count - 30;
        end else if (count < 50) begin
            tens_digit = 4'b0100;
            units_digit = count - 40;
        end else if (count < 60) begin
            tens_digit = 4'b0101;
            units_digit = count - 50;
        end else begin // 60-63
            tens_digit = 4'b0110;
            units_digit = count - 60;
        end
    end

    // 4. Decoder a display 7 segmentos
   decoder_segmentos display_decenas (
        .data(tens_digit),
        .segments(segments_tens)
    );
	 
	 decoder_segmentos display_unidades (
        .data(units_digit),
        .segments(segments_units)
    );
endmodule
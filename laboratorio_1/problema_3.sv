module problema_3 #(parameter WIDTH=4)(
    input  logic clk,
    input  logic reset_n,
    input  logic button,
    output logic [6:0] segments
);
    logic [WIDTH-1:0] count;
    logic overflow;
    logic button_pulse;

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

    // 3. Decoder a display 7 segmentos
   decoder_segmentos decoder (
        .data(count),
        .segments(segments)
    );
endmodule
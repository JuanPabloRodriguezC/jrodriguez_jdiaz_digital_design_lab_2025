// Multiplexor para seleccionar señales

module mux2 (
    input logic [7:0] d0,
    input logic [7:0] d1,
    input logic set_mux,
    output logic [7:0] y
);
    assign y = set_mux ? d0 : d1;
endmodule
module timer #(
    parameter CLOCK_FREQ = 50_000_000  // 50 MHz
)(
    input  logic       clk,
    input  logic       rst,           // Reset activo en alto
    input  logic       enable,        // Enable para contar
    output logic       timeout,       // Pulso cuando llega a 0
    output logic [6:0] segments_units,
    output logic [6:0] segments_tens
);

    localparam int COUNTS_PER_SECOND = CLOCK_FREQ;
    localparam int START_VALUE = 15;
    
    logic [31:0] counter;
    logic [3:0]  time_value;  // 0-15
    logic [3:0]  units, tens;
    
    // Contador principal
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            time_value <= START_VALUE;
            timeout <= 1'b0;
        end else if (enable) begin
            timeout <= 1'b0;  // Default
            
            if (counter >= COUNTS_PER_SECOND - 1) begin
                counter <= 0;
                
                if (time_value > 0) begin
                    time_value <= time_value - 1;
                end else begin
                    // Llegó a 0
                    timeout <= 1'b1;
                    time_value <= START_VALUE;  // Reiniciar para próxima vez
                end
            end else begin
                counter <= counter + 1;
            end
        end else begin
            // No está habilitado, mantener valor actual
            timeout <= 1'b0;
        end
    end
    
    // Convertir a BCD (unidades y decenas)
    always_comb begin
        tens = time_value / 10;
        units = time_value % 10;
    end
    
    // Decodificadores BCD a 7 segmentos
    bcd_to_7seg u_units(
        .bcd(units),
        .segments(segments_units)
    );
    
    bcd_to_7seg u_tens(
        .bcd(tens),
        .segments(segments_tens)
    );

endmodule
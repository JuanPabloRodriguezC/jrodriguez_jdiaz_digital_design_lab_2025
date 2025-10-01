module timer #(
    parameter MAX_COUNT = 50000000  // Default: 1 second at 50MHz
)(
    input  logic        clk,
    input  logic        rst,           // Active high reset
    input  logic        enable,        // Enable counting
    output logic        timeout,       // Pulse when timeout reached
    output logic [31:0] count_value    // Current count value
);

    logic [31:0] counter;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 32'b0;
            timeout <= 1'b0;
        end
        else if (enable) begin
            if (counter >= MAX_COUNT - 1) begin
                counter <= 32'b0;
                timeout <= 1'b1;
            end
            else begin
                counter <= counter + 1;
                timeout <= 1'b0;
            end
        end
        else begin
            counter <= 32'b0;
            timeout <= 1'b0;
        end
    end
    
    assign count_value = counter;

endmodule
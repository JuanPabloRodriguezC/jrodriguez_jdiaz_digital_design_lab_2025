`timescale 1ns/1ps

module problema_3_tb;
    parameter WIDTH = 4;

    logic clk;
    logic reset_n;
    logic button;
    logic [6:0] segments_tens;
	 logic [6:0] segments_units;

    
    problema_3 #(.WIDTH(WIDTH)) dut (
        .clk(clk),
        .reset_n(reset_n),
        .button(button),
        .segments_tens(segments_tens),
		  .segments_units(segments_units)
    );

    // Generador de reloj (100 MHz → periodo 10 ns)
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset_n = 0;
        button  = 0;
        #20;

        reset_n = 1;
        #20;

        press_button();

        #50;
     
        press_button();

        #50;
        
        bounce_button();

        #200;

 
    end

    // Tarea: pulsación limpia
    task press_button;
        begin
            button = 1;
            #15;   // mantener 15 ns
            button = 0;
        end
    endtask

    task bounce_button;
        begin
            button = 1; #5;
            button = 0; #5;
            button = 1; #5;
            button = 0; #5;
            button = 1; #10;
            button = 0;
        end
    endtask

endmodule

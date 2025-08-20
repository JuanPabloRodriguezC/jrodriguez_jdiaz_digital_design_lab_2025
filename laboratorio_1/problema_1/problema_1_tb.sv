module problema_1_tb();
    logic [3:0] binary_in;
    logic [3:0] gray_out;
    
    problema_1 #(.WIDTH(4)) dut(.binary_in(binary_in), .gray_out(gray_out));
    
    initial begin
       
        binary_in = 4'b0000;
        #40;
        binary_in = 4'b1110;
        #40;
        binary_in = 4'b1010;
        #40;
        binary_in = 4'b1011;
        #40;
        binary_in = 4'b0010;
        #40;
        binary_in = 4'b1000;
        #40;
        binary_in = 4'b0101;
        #40;
        binary_in = 4'b0011;
        #40;
        binary_in = 4'b1111;
        #40;
    end
endmodule
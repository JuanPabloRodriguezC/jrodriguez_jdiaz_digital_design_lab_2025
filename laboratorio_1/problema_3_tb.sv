module problema_3_tb;
	logic clk;
	logic reset_n;
	logic enable;
	logic[7:0] count;
	logic overflow;
	
	problema_3 #(.WIDTH(8)) dut (
		.clk(clk),
		.reset_n(reset_n),
		.enable(enable),
		.count(count),
		.overflow(overflow)
	);
	
	initial begin
		clk=0;
		forever #5 clk = ~clk;
	end
	
	initial begin
		reset_n = 0;
		enable = 0;
		
		#20
		reset_n = 1;
		#20
		enable = 1;
		#2550;
		reset_n = 0;
		#20
		reset_n = 1;
		
		#100 
		$finish;
	end
endmodule
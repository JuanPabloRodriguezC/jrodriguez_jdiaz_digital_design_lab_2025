module multiplicadorCompletoN #(parameter WIDTH=4)(
	input logic [WIDTH-1:0] multiplicando;
	input logic [WIDTH-1:0] multiplicador;	
	output logic [31:0] res;
)(
	logic [2*WIDTH-1:-] res_parcial;
	logic [2*WIDTH-1:-] mult_desplazado;
	logic [2*WIDTH-1:-] suma_res;
	
	logic [WIDTH] cout;
	assign res_parcial[0] = '0;
	
	genvar i
	generate
		for(int i=1; i < WIDTH;i++) begin
        assign mult_desplazado[i] = {{WIDTH{1'b0}}, multiplicando} << 1;
		  
		  
		  sumadorCompletoN #(.WIDTH(2*WIDTH)) sumador (
			.A(res_parcial[i]),
			.B(mult_desplazado[i]),
			.Cin(1'b0),
			.S(suma_res[i]),
			.Cout(cout[i])
			);
		  
			if multiplicador[i] == 1 begin
				assign res_parcial[i+1] = suma_res;
			else
				assign res_parcial[i+1] = res_parcial[i];
			end
		end
	endgenerate
	assign res = res_parcial[WIDTH];
endmodule
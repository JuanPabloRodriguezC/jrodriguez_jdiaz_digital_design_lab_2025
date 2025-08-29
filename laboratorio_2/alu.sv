// ALU parametrizable con suma y resta
module alu #(parameter WIDTH=4)(
    input  logic [WIDTH-1:0] A,
    input  logic [WIDTH-1:0] B,
    input  logic boton0,
	 input  logic boton1, 
	 input  logic boton2,
	 input  logic boton3,
	 
    input  logic Cin,
	 
    
    output logic [WIDTH-1:0] S,
    output logic Cout
);

    // Botones en un vector de 4 bits para contolar las operaciones
    logic [3:0] botones;
    assign botones = {boton3, boton2, boton1, boton0};
	 
	 // Señales internas (para que todo no este manejado al mismo S)
    logic [WIDTH-1:0] sum_S, rest_S, div_S, mod_S;
    logic sum_Cout, rest_Cout;
    logic [WIDTH-1:0] and_S, or_S, xor_S;

    // 1. Sumador parametrizable
    sumadorCompletoN #(.WIDTH(WIDTH)) u_sumador (
        .A(A),
        .B(B),
        .Cin(Cin),
        .S(sum_S),
        .Cout(sum_Cout)
    );

    // 2. Restador parametrizable
    restadorCompletoN #(.WIDTH(WIDTH)) u_restador (
        .A(A),
        .B(B),
        .Cin(Cin),
        .S(rest_S),
        .Cout(rest_Cout)
    );
	 
	 // 3. Multiplicacion parametrizable
	 
	 // Esta tiene que ser con tabla de verdad. Se hara despues
	 
	 // 4. Division parametrizable
	 
	 assign div_S = A / B;
	 
	 // 5. Modulo parametrizable
	 
	 assign mod_S = A % B;
	 
	 // 6. Operaciones logicas AND, OR, XOR
	 
	 assign and_S = A & B; // AND
	 
	 assign or_S = A | B; // OR
	 
	 assign xor_S = A ^ B; // XOR
	 

	 // 7. Shift left y right
	 
	 // assign resultado_shiftL = A << 1; // Left
	 
	 // assign resultado_shiftR = A >> 1; // Right
	 
	 // 8. Case para elegir opciones
   
	always_comb begin
        S = {WIDTH{1'b0}}; 
        Cout = 1'b0;

        case(botones)
            4'b0001: begin S = sum_S;  Cout = sum_Cout;  end // Botón en 1 = Suma, begin y end porque inicia un bloque de mas de una instruccion
            4'b0010: begin S = rest_S; Cout = rest_Cout; end // Botón en 2 = Resta
				
				//multiplicacion // Botón 3 = Multiplicacion
				
            4'b0100: S = div_S;       // Botón en 4 = division
            4'b0101: S = mod_S;        // Botón en 5 = modulo
				4'b0110: S = and_S;			// Boton en 6 = AND
				4'b0111: S = or_S;			// Boton en 7 = OR
				4'b1000: S = xor_S;			// Boton en 8 = XOR
				
				
            default: S = {WIDTH{1'b0}}; //asegura un default
        endcase
    end

endmodule
module fsm(input logic clk,
			  input logic rst,
			  input logic boton,
			  input logic timeoutx,
			  input logic timeout1,
			  input logic timeout5,
			  
			  
			  output logic enx,
			  output logic rstx,
			  output logic en1,
			  output logic rst1,
			  output logic en5,
			  output logic rst5,
			  output logic vehicRojo,
			  output logic vehicAmarillo,
			  output logic vehicVerde,
			  output logic peatVerde,
			  output logic peatRojo
			  
			  
);

typedef enum logic [1:0] {Q0, Q1, Q2, Q3} state;

state current, next;

// Detector de flanco del botón (switch)
logic boton_prev;
logic boton_edge;

always_ff @(posedge clk or posedge rst) begin
	if(rst) begin
		current <= Q0;
		boton_prev <= 1'b0;
	end else begin
		current <= next;
		boton_prev <= boton;
	end
end

// Detectar flanco de subida del switch
assign boton_edge = boton & ~boton_prev;
	
// logica combinacional de caso actual a siguiente estado
always_comb begin
	next = current; // Valor por defecto
	
	case(current)
		Q0: if(boton_edge) next = Q2;
			 else 	        next = Q1;
			 
		Q1: if(timeoutx) next = Q2;
			 else         next = Q0;
			 
		Q2: if(timeout1) next = Q3;
			 else         next = Q2;
			 
		Q3: if(timeout5) next = Q0;
			 else         next = Q3;	
		
		default: next = Q0;
	endcase
end
	
	// asignar salidas segun estado
	assign enx = (current == Q0 | current == Q1);
	assign en1 = (current == Q2);
	assign en5 = (current == Q3);
	
	assign vehicVerde = (current == Q0 | current == Q1);
	assign vehicAmarillo = (current == Q2);
	assign vehicRojo = (current == Q3);
	
	assign peatRojo = (current == Q0 | current == Q1 | current == Q2);
	assign peatVerde = (current == Q3);
	
	assign rstx = (current == Q2) | (current == Q3);
	assign rst1 = (current == Q0) | (current == Q1) | (current == Q3);
	assign rst5 = (current == Q0) | (current == Q1) | (current == Q2);

endmodule
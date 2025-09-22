module FSM(
    input [3:0] x, 
    input clk, rst,
    output [3:0] a, b
);
logic [3:0] timer;
logic [3:0] puntjae1;
logic [3:0] puntaje2;
logic [1:0] cartas_seleccionadas;
logic [3:0] carta1;
logic [3:0] carta2;
logic estado_seleccion;
logic turno;
logic [4:0] num_cartas_disponibles;

logic [2:0] state, next_state;

//actual state logic

always_ff @(posedge clk or posedge rst)
	if (rst) state = 2'b00;
	else
		state = next_state;

//next state logic

always_comb
	case(state)
	3'b000: 
        if (x) begin
            if (cartas_seleccionadas == 3'b010) next_state = 3'b001;
            else begin
                next_state = current_state; //mantiene el estado actual
                cartas_seleccionadas = cartas_seleccionadas + 1;
                //implementa logica de guardar carta seleccionada
            end 
            
        end
        else next_state = 3'b011;
	3'b001: 
        if(estado_seleccion) next_state = 3'b010;
        else begin
            turno = ~turno;
            next_state = 3'b000;
        end
	3'b010: 
        if (num_cartas_disponibles == 5'b00000) next_state = 3'b101;
        else next_state = 3'b000;
	3'b011: 
        if (timer < 4'b1111) next_state = 3'b000;
        else next_state = 3'b100;
    3'b100: 
        //implementa sleecion aleatoria de cartas
        next_state = 3'b001;
	default next_state = 3'b000;
	endcase
	
	
//outputs logic

assign a = (state == 2'b10);
assign b = (state == 2'b11);


endmodule
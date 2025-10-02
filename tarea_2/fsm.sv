module FSM(input m, t0, clk, reset, output rst_tiempo, cont, set_mux);

typedef enum logic [1:0] {S0, S1, S2, S3} statetype;
statetype state, next_state;

// actual state logic
always_ff @(posedge clk, posedge reset)
    if (reset) state <= S0;
    else state <= next_state;

// next state logic
always_comb
    case (state)
        S0: if(m) next_state = S1; else next_state = S2;
        S1: next_state = S0;
        S2: if(t0) next_state = S3; else next_state = S0;
        S3: if(reset) next_state = S0; else next_state = S3;
        default: next_state= S0;
    endcase

// outputs logic
assign cont = (state == S1);
assign rst_tiempo = (state == S1);
assign set_mux = (state == S3);  

endmodule
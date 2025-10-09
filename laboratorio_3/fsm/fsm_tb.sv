`timescale 1ns / 1ps

module fsm_tb;

    // Testbench signals
    logic       clk;
    logic       rst;
    logic       carta_recibida;
    logic [3:0] card_id;
    logic [3:0] random_card1;
    logic [3:0] random_card2;
    
    // Outputs
    logic [3:0] carta1;
    logic [3:0] carta2;
    logic [3:0] puntaje1;
    logic [3:0] puntaje2;
    logic       turno;
    logic [4:0] num_cartas_disponibles;
    logic       timer_reset;
    logic       timer_enable;
    logic [2:0] state_out;
    
    // Timer signals
    logic       timer_timeout;
    logic [31:0] timer_count;
    
    parameter TIMEOUT_CYCLES = 50;  // Very short for quick simulation
    
    // Timer instantiation
    timer #(
        .MAX_COUNT(TIMEOUT_CYCLES)
    ) game_timer (
        .clk(clk),
        .rst(timer_reset),
        .enable(timer_enable),
        .timeout(timer_timeout),
        .count_value(timer_count)
    );
    
    // FSM instantiation
    fsm dut (
        .clk(clk),
        .rst(rst),
        .carta_recibida(carta_recibida),
        .card_id(card_id),
        .timer_timeout(timer_timeout),
        .random_card1(random_card1),
        .random_card2(random_card2),
        .carta1(carta1),
        .carta2(carta2),
        .puntaje1(puntaje1),
        .puntaje2(puntaje2),
        .turno(turno),
        .num_cartas_disponibles(num_cartas_disponibles),
        .timer_reset(timer_reset),
        .timer_enable(timer_enable),
        .state_out(state_out)
    );
    
    // Clock generation - 50 MHz
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        // Initialize
        rst = 1;
        carta_recibida = 0;
        card_id = 0;
        random_card1 = 5;
        random_card2 = 5;
        
        // Reset
        #40;
        rst = 0;
        
        // TEST 1: Player 1 makes a match
        #60;
        carta_recibida = 1;
        card_id = 3;
        #20;
        carta_recibida = 0;
        
        #60;
        carta_recibida = 1;
        card_id = 3;
        #20;
        carta_recibida = 0;
        
        // TEST 2: Player 1 doesn't match
        #100;
        carta_recibida = 1;
        card_id = 7;
        #20;
        carta_recibida = 0;
        
        #60;
        carta_recibida = 1;
        card_id = 9;
        #20;
        carta_recibida = 0;
        
        // TEST 3: Wait for timeout (no button press)
        #2000;  // Let timer reach timeout
        
        // End simulation
        #500;
    end

endmodule
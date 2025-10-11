`timescale 1ns/1ps

module fsm_tb();

    // Señales del DUT
    logic       clk;
    logic       rst;
    logic       carta_recibida;
    logic       timer_timeout;
    logic       cards_match;
    logic       game_over;
    logic [3:0] carta1_pos;
    logic [3:0] carta2_pos;
    
    logic        enable_score1;
    logic        enable_score2;
    logic        load_carta1;
    logic        load_carta2;
    logic        mark_match;
    logic        selector_carta;
    logic        timer_reset;
    logic        timer_enable;
    logic        use_random;
    logic        turno;
    logic [15:0] cards_face_up;
    
    // Generación del reloj - 50 MHz
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
    
    fsm dut(
        .clk(clk),
        .rst(rst),
        .carta_recibida(carta_recibida),
        .timer_timeout(timer_timeout),
        .cards_match(cards_match),
        .game_over(game_over),
        .carta1_pos(carta1_pos),
        .carta2_pos(carta2_pos),
        .enable_score1(enable_score1),
        .enable_score2(enable_score2),
        .load_carta1(load_carta1),
        .load_carta2(load_carta2),
        .mark_match(mark_match),
        .selector_carta(selector_carta),
        .timer_reset(timer_reset),
        .timer_enable(timer_enable),
        .use_random(use_random),
        .turno(turno),
        .cards_face_up(cards_face_up)
    );
    
    initial begin
        $display("\n=== Testbench FSM - Juego de Memoria ===\n");
        
        // Inicializar señales
        rst = 1;
        carta_recibida = 0;
        timer_timeout = 0;
        cards_match = 0;
        game_over = 0;
        carta1_pos = 4'h0;
        carta2_pos = 4'h0;
        
        // Reset
        #50;
        rst = 0;
        #20;
        
        $display("[TEST 1] Reset - Estado inicial");
        $display("Estado esperado: WAIT_CARD1, timer_enable=1, turno=0");
        $display("Estado actual: state=%b, timer_enable=%b, turno=%b\n", 
                 dut.state, timer_enable, turno);
        
        // ==========================================
        // TEST 2: Seleccionar dos cartas que coinciden
        // ==========================================
        $display("[TEST 2] Dos cartas que coinciden");
        carta1_pos = 4'h3;
        carta2_pos = 4'h7;
        
        // Primera carta
        #20;
        carta_recibida = 1;
        #20;
        carta_recibida = 0;
        #40;
        $display("Después de carta 1: state=%b, selector_carta=%b", 
                 dut.state, selector_carta);
        
        // Segunda carta
        carta_recibida = 1;
        #20;
        carta_recibida = 0;
        #60;
        $display("Después de carta 2: state=%b (debería estar en SHOW_CARDS)", 
                 dut.state);
        
        // Esperar un poco y marcar coincidencia
        #200;
        cards_match = 1;
        #20;
        $display("Coincidencia: state=%b, mark_match=%b, enable_score1=%b", 
                 dut.state, mark_match, enable_score1);
        
        cards_match = 0;
        #40;
        $display("Regresa a WAIT_CARD1: state=%b, turno=%b (debería seguir en 0)\n", 
                 dut.state, turno);
        
        // ==========================================
        // TEST 3: Cartas que NO coinciden
        // ==========================================
        $display("[TEST 3] Dos cartas que NO coinciden");
        carta1_pos = 4'h1;
        carta2_pos = 4'h5;
        
        // Primera carta
        #20;
        carta_recibida = 1;
        #20;
        carta_recibida = 0;
        #40;
        
        // Segunda carta
        carta_recibida = 1;
        #20;
        carta_recibida = 0;
        #60;
        
        // NO coinciden
        cards_match = 0;
        #200;
        
        $display("Sin coincidencia: state=%b, turno=%b (debería cambiar a 1)\n", 
                 dut.state, turno);
        
        // ==========================================
        // TEST 4: Timeout del timer
        // ==========================================
        $display("[TEST 4] Timeout del timer");
        
        #20;
        timer_timeout = 1;
        #20;
        timer_timeout = 0;
        #40;
        
        $display("Después de timeout: state=%b, use_random=%b (debería ir a RANDOM_SELECT)\n", 
                 dut.state, use_random);
        
        // ==========================================
        // TEST 5: Game Over
        // ==========================================
        $display("[TEST 5] Game Over");
        
        // Reset rápido
        rst = 1;
        #20;
        rst = 0;
        #20;
        
        // Hacer una jugada rápida
        carta_recibida = 1;
        #20;
        carta_recibida = 0;
        #40;
        carta_recibida = 1;
        #20;
        carta_recibida = 0;
        #60;
        
        cards_match = 1;
        #200;
        
        // Activar game over
        game_over = 1;
        #40;
        
        $display("Game Over: state=%b, timer_enable=%b (debería estar en GAME_OVER)\n", 
                 dut.state, timer_enable);
        
        $display("=== Fin del Testbench ===");
        
        #100;
        $finish;
    end

endmodule
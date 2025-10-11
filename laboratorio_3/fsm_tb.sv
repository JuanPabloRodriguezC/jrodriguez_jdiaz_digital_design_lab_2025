`timescale 1ns / 1ps

module FSM_tb;
    logic       clk;
    logic       rst;
    logic       carta_recibida;
    logic [3:0] card_id;
    logic [3:0] random_card1;
    logic [3:0] random_card2;
    
    logic [3:0] carta1;
    logic [3:0] carta2;
    logic [3:0] puntaje1;
    logic [3:0] puntaje2;
    logic       turno;
    logic [4:0] num_cartas_disponibles;
    logic       timer_reset;
    logic       timer_enable;
    logic [2:0] state_out;
    

    logic       timer_timeout;
    logic [31:0] timer_count;
    
    parameter TIMEOUT_CYCLES = 100; 
    
    timer #(
        .MAX_COUNT(TIMEOUT_CYCLES)
    ) game_timer (
        .clk(clk),
        .rst(timer_reset),
        .enable(timer_enable),
        .timeout(timer_timeout),
        .count_value(timer_count)
    );
    
    FSM dut (
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
    
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // 20ns period
    end
    
    task reset_system;
        begin
            rst = 1;
            carta_recibida = 0;
            card_id = 0;
            random_card1 = 0;
            random_card2 = 0;
            repeat(3) @(posedge clk);
            rst = 0;
            @(posedge clk);
            $display("=== SYSTEM RESET ===");
        end
    endtask

    task select_card(input [3:0] card);
        begin
            @(posedge clk);
            carta_recibida = 1;
            card_id = card;
            @(posedge clk);
            carta_recibida = 0;
            @(posedge clk);
            $display("Card %0d selected at time %0t", card, $time);
        end
    endtask
    
    //==============================================
    // Task: Wait for Timeout
    //==============================================
    task wait_for_timeout;
        begin
            $display("Waiting for timeout... (timer at %0d/%0d)", timer_count, TIMEOUT_CYCLES);
            @(posedge timer_timeout);
            $display("TIMEOUT occurred at time %0t", $time);
            repeat(3) @(posedge clk);
        end
    endtask
    
    //==============================================
    // Task: Display Current State
    //==============================================
    task display_state;
        begin
            $display("----------------------------------------");
            $display("Time: %0t | State: %0d", $time, state_out);
            $display("Carta1: %0d | Carta2: %0d", carta1, carta2);
            $display("P1 Score: %0d | P2 Score: %0d", puntaje1, puntaje2);
            $display("Turn: Player %0d | Cards Left: %0d", turno+1, num_cartas_disponibles);
            $display("Timer: %0d/%0d | Enable: %0b | Reset: %0b", 
                     timer_count, TIMEOUT_CYCLES, timer_enable, timer_reset);
            $display("Timeout Signal: %0b", timer_timeout);
            $display("----------------------------------------");
        end
    endtask
    
    //==============================================
    // Main Test Sequence
    //==============================================
    initial begin
        $display("\n========================================");
        $display("   FSM + TIMER TESTBENCH STARTED");
        $display("   Timeout Period: %0d clock cycles", TIMEOUT_CYCLES);
        $display("========================================\n");
        
        // Initialize
        reset_system();
        display_state();
        
        //==========================================
        // TEST 1: Normal Match (Player 1 wins)
        //==========================================
        $display("\n=== TEST 1: Player 1 Selects Matching Cards (Before Timeout) ===");
        select_card(4'd0);  // Select first card
        display_state();
        
        select_card(4'd0);  // Select same card (match)
        repeat(3) @(posedge clk);
        display_state();
        
        // Verify timer was reset
        if (timer_count < 10) begin
            $display("✓ Timer properly reset after match");
        end else begin
            $display("✗ ERROR: Timer not reset properly!");
        end
        
        //==========================================
        // TEST 2: No Match (Turn Changes)
        //==========================================
        $display("\n=== TEST 2: Player 1 Selects Non-Matching Cards ===");
        select_card(4'd1);  // Select first card
        display_state();
        
        select_card(4'd2);  // Select different card (no match)
        repeat(3) @(posedge clk);
        display_state();
        
        // Verify timer was reset and turn changed
        if (timer_count < 10) begin
            $display("✓ Timer properly reset after no match");
        end else begin
            $display("✗ ERROR: Timer not reset properly!");
        end
        
        //==========================================
        // TEST 3: Timeout in State 0 (Real Timer)
        //==========================================
        $display("\n=== TEST 3: Real Timeout While Waiting for First Card ===");
        random_card1 = 4'd5;
        random_card2 = 4'd5;
        
        // DON'T select any card - let timer expire
        wait_for_timeout();
        display_state();
        
        // Check if FSM went to random selection state
        if (state_out == 3'b100 || state_out == 3'b010) begin
            $display("✓ FSM correctly handled timeout");
        end else begin
            $display("✗ ERROR: FSM in wrong state after timeout");
        end
        
        //==========================================
        // TEST 4: Timeout in State 1 (Real Timer)
        //==========================================
        $display("\n=== TEST 4: Real Timeout While Waiting for Second Card ===");
        select_card(4'd7);  // Select first card
        display_state();
        
        random_card1 = 4'd8;
        random_card2 = 4'd9;
        
        // DON'T select second card - let timer expire
        wait_for_timeout();
        display_state();
        
        //==========================================
        // TEST 5: Quick Selection (Before Timeout)
        //==========================================
        $display("\n=== TEST 5: Player Selects Cards Quickly (No Timeout) ===");
        
        // Select both cards quickly (within a few cycles)
        select_card(4'd10);
        repeat(5) @(posedge clk);  // Small delay, but well before timeout
        select_card(4'd10);
        repeat(3) @(posedge clk);
        display_state();
        
        $display("Timer was at: %0d/%0d when cards were selected", timer_count, TIMEOUT_CYCLES);
        
        //==========================================
        // Final State Display
        //==========================================
        $display("\n=== FINAL GAME STATE ===");
        display_state();
        
        // End simulation
        repeat(10) @(posedge clk);
        $display("\n========================================");
        $display("   FSM + TIMER TESTBENCH COMPLETED");
        $display("========================================\n");
        $finish;
    end
    
    //==============================================
    // Monitor State Changes
    //==============================================
    always @(posedge clk) begin
        if (state_out != dut.state) begin
            case (dut.state)
                3'b000: $display("[%0t] STATE CHANGE → S0_WAIT_CARD1", $time);
                3'b001: $display("[%0t] STATE CHANGE → S1_WAIT_CARD2", $time);
                3'b010: $display("[%0t] STATE CHANGE → S2_CHECK_MATCH", $time);
                3'b011: $display("[%0t] STATE CHANGE → S3_PLAYER_SCORED", $time);
                3'b100: $display("[%0t] STATE CHANGE → S4_RANDOM_SELECT", $time);
                3'b101: $display("[%0t] STATE CHANGE → S5_GAME_OVER", $time);
            endcase
        end
    end
    
    //==============================================
    // Monitor Timer Events
    //==============================================
    always @(posedge clk) begin
        if (timer_reset) begin
            $display("[%0t] ⟳ Timer Reset", $time);
        end
    end
    
    //==============================================
    // Timeout for Safety
    //==============================================
    initial begin
        #50000;  // 50 microseconds
        $display("ERROR: Testbench timeout!");
        $finish;
    end

endmodule
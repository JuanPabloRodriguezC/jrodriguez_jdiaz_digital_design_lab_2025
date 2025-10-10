module cursorController(
    input  logic       clk,
    input  logic       rst,
    input  logic       btn_up,
    input  logic       btn_down,
    input  logic       btn_left,
    input  logic       btn_right,
    input  logic       btn_select,
    input  logic       selector_carta,
    input  logic [15:0] cards_matched,
    
    output logic [3:0] cursor_pos,
    output logic       carta_recibida
);
    logic [3:0] cursor_reg;
    logic [3:0] carta1_saved;
    logic [4:0] btn_prev;
    logic btn_up_edge, btn_down_edge, btn_left_edge, btn_right_edge, btn_select_edge;
    logic [19:0] debounce_counter;
    logic debounce_ready;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            debounce_counter <= 20'd0;
            debounce_ready <= 1'b1;
        end else begin
            if (debounce_counter > 0) begin
                debounce_counter <= debounce_counter - 1;
                debounce_ready <= 1'b0;
            end else begin
                debounce_ready <= 1'b1;
            end
            
            if ((btn_up_edge || btn_down_edge || btn_left_edge || btn_right_edge || btn_select_edge) && debounce_ready) begin
                debounce_counter <= 20'd500000;
            end
        end
    end
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            btn_prev <= 5'b00000;
        else
            btn_prev <= {btn_select, btn_right, btn_left, btn_down, btn_up};
    end
    
    assign btn_up_edge     = btn_up     && !btn_prev[0] && debounce_ready;
    assign btn_down_edge   = btn_down   && !btn_prev[1] && debounce_ready;
    assign btn_left_edge   = btn_left   && !btn_prev[2] && debounce_ready;
    assign btn_right_edge  = btn_right  && !btn_prev[3] && debounce_ready;
    assign btn_select_edge = btn_select && !btn_prev[4] && debounce_ready;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cursor_reg <= 4'd0;
        end else begin
            if (btn_up_edge && cursor_reg >= 4)
                cursor_reg <= cursor_reg - 4'd4;
            else if (btn_down_edge && cursor_reg < 12)
                cursor_reg <= cursor_reg + 4'd4;
            else if (btn_left_edge && cursor_reg[1:0] != 2'b00)
                cursor_reg <= cursor_reg - 4'd1;
            else if (btn_right_edge && cursor_reg[1:0] != 2'b11)
                cursor_reg <= cursor_reg + 4'd1;
        end
    end
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            carta1_saved <= 4'h0;
        end else begin
            if (selector_carta == 1'b0 && btn_select_edge && !cards_matched[cursor_reg])
                carta1_saved <= cursor_reg;
        end
    end
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            carta_recibida <= 1'b0;
        end else begin
            carta_recibida <= 1'b0;
            
            if (btn_select_edge && !cards_matched[cursor_reg]) begin
                if (selector_carta == 1'b0) begin
                    carta_recibida <= 1'b1;
                end else begin
                    if (cursor_reg != carta1_saved)
                        carta_recibida <= 1'b1;
                end
            end
        end
    end
    
    assign cursor_pos = cursor_reg;
endmodule
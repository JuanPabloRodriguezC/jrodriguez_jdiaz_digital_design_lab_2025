
module Examen1 (
	input logic clk,
	input logic rst,
	input logic boton,
	
	output logic vehicRojo,
	output logic vehicAmarillo,
	output logic vehicVerde,
	output logic peatVerde,
	output logic peatRojo
);

  
    // Señales de control de la FSM
  logic       enx, en1, en5;
  logic       rstx, rst1, rst5;
  logic       timeoutx;
  logic       timeout1;
  logic       timeout5;
  
  
  contador #(
    .segundos(10)
  ) u_contadorx (
    .clk            (clk),
    .rst            (rstx),
    .enable         (enx),
    .timeout        (timeoutx)
  );
  
  contador #(
    .segundos(1)
  ) u_contador1 (
    .clk            (clk),
    .rst            (rst1),
    .enable         (en1),
    .timeout        (timeout1)
  );
  
  contador #(
    .segundos(5)
  ) u_contador5 (
    .clk            (clk),
    .rst            (rst5),
    .enable         (en5),
    .timeout        (timeout5)
  );
  
 fsm u_fsm(
    .clk              (clk),
    .rst              (rst),
	 .boton            (boton),
	 .timeoutx         (timeoutx),
	 .timeout1         (timeout1),
	 .timeout5         (timeout5),
	 
	 .enx              (enx),
	 .en1              (en1),
	 .en5              (en5),
	 .rstx             (rstx),
	 .rst1             (rst1),
	 .rst5             (rst5),
	 .vehicRojo        (vehicRojo),
	 .vehicAmarillo    (vehicAmarillo),
	 .vehicVerde       (vehicVerde),
	 .peatVerde        (peatVerde),
	 .peatRojo         (peatRojo)
  );
  
endmodule
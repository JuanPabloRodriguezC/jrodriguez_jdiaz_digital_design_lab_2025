`timescale 1ns/1ps

module tb_main;

  // Señales
  reg clk;
  reg reset;
  reg m;
  wire [7:0] estado;

  // Instancia del DUT (Device Under Test)
  main dut (
    .clk(clk),
    .reset(reset),
    .m(m),
    .estado(estado)
  );

  // Generador de reloj: periodo = 10ns (100 MHz)
  initial clk = 0;
  always #5 clk = ~clk;

  // Estímulos
  initial begin
    // Inicialización
    reset = 1;
    m = 0;
    #20;          // mantener reset un rato
    reset = 0;

    // Caso 1: Presionar botón de mantenimiento antes de 200 ciclos
    #50;          // esperar 50ns
    m = 1;        // presionar botón
    #10;
    m = 0;        // soltar botón
    #100;         // dejar correr un tiempo

    // Caso 2: No presionar el botón (debería entrar en error)
    
    #2000;        // esperar suficiente tiempo -> t0 se activa

    // Fin de la simulación
    #200;
    $stop;        // detener simulación en ModelSim
  end

  // Monitoreo en consola
  initial begin
    $display("Tiempo\tclk\treset\tm\testado");
    $monitor("%0t\t%b\t%b\t%b\t%h", $time, clk, reset, m, estado);
  end

endmodule


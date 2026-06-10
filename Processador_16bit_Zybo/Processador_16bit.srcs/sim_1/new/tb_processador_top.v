`timescale 1ns / 1ps

module tb_processador_top();

    reg clk;
    reg rst;
    reg [15:0] in_port; // O nosso "teclado"
    wire [15:0] out_port; // O nosso "monitor"

    // Instancia o processador
    processador_top dut (
        .clk(clk),
        .rst(rst),
        .in_port(in_port),
        .out_port(out_port)
    );

    // Gera o Clock de 10ns
    always #5 clk = ~clk;

    initial begin
        // Inicialização
        clk = 0;
        rst = 1;
        in_port = 16'd3; // <-- Simulando que o usuário digitou '3' para o loop rodar 3 vezes

        // Solta o reset
        #15;
        rst = 0;

        // Espera tempo suficiente para o programa inteiro rodar (Tem loop, então precisa de tempo)
        #2000;

        $display("Simulação Terminada. O valor no OUT_PORT é: %d", out_port);
        $finish;
    end

endmodule
`timescale 1ns / 1ps

module tb_cpu_top();

    reg  clk;
    reg  rst;
    reg  [15:0] in_port;     // chaves
    wire [15:0] out_port;    // LEDs
    wire        halt_out;

    cpu_top uut (
        .clk(clk),
        .rst(rst),
        .in_port(in_port),
        .out_port(out_port),
        .halt_out(halt_out)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        in_port = 16'h0000;

        #20;
        rst = 0;

        $display("Programa rodando: LEDs devem seguir as chaves (via processador)...");

        // Muda as "chaves" e espera o processador copiar para a saida
        in_port = 16'h0005; #200;
        $display("chaves=%b  ->  LEDs(out_port[3:0])=%b", in_port[3:0], out_port[3:0]);

        in_port = 16'h000A; #200;
        $display("chaves=%b  ->  LEDs(out_port[3:0])=%b", in_port[3:0], out_port[3:0]);

        in_port = 16'h000F; #200;
        $display("chaves=%b  ->  LEDs(out_port[3:0])=%b", in_port[3:0], out_port[3:0]);

        $display("Simulacao finalizada.");
        $finish;
    end

endmodule

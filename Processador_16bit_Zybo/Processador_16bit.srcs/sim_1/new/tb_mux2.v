`timescale 1ns / 1ps

module tb_mux2();

    // Entradas do testbench viram 'reg'
    reg  [15:0] I0;
    reg  [15:0] I1;
    reg         sel;
    
    // Saída vira 'wire'
    wire [15:0] out;

    // Instanciação do módulo
    mux2 dut (
        .I0(I0),
        .I1(I1),
        .sel(sel),
        .out(out)
    );

    initial begin
        // Inicializa as entradas com valores bem distintos (em Hexadecimal)
        I0 = 16'hAAAA; 
        I1 = 16'h5555;
        
        // TESTE 1: Chave em 0 (Deve sair AAAA)
        sel = 0;
        #10;
        
        // TESTE 2: Chave em 1 (Deve sair 5555)
        sel = 1;
        #10;
        
        // TESTE 3: Mudando a entrada enquanto a chave está em 1
        I1 = 16'h9999;
        #10; // A saída deve atualizar automaticamente para 9999
        
        $display("Fim dos testes do MUX 2x1!");
        $finish;
    end

endmodule
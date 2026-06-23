`timescale 1ns / 1ps
module tb_memory_inst();
    reg clk, rd, wr;
    reg [7:0] addr;
    reg [15:0] data_in; // Sinal interno para simular escrita
    wire [15:0] data;   // Barramento bidirecional real
    
    // Controlador tri-state do Testbench
    assign data = (wr) ? data_in : 16'bz;

    memory_inst #(8, 16) dut (.clk(clk), .rd(rd), .wr(wr), .addr(addr), .data(data));

    always #5 clk = ~clk;

    initial begin
        clk = 0; rd = 0; wr = 0; addr = 8'h00; data_in = 16'h0000; #10;
        
        // 1. Testa Leitura Assíncrona do programa pré-gravado
        rd = 1; addr = 8'h0A; #10; // Deve ler '5' imediatamente
        
        // 2. Testa Escrita Síncrona
        rd = 0; wr = 1; addr = 8'hFF; data_in = 16'hCAFE; #10; // Grava no endereço FF
        
        // 3. Lê o que acabou de gravar
        wr = 0; rd = 1; addr = 8'hFF; #10; // Deve mostrar 'CAFE'
        
        $finish;
    end
endmodule
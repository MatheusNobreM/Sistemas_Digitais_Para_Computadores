`timescale 1ns / 1ps

module tb_ram();

    reg         clk;
    reg         wr_en;
    reg  [15:0] addr;
    reg  [15:0] din;
    
    wire [15:0] dout;

    
    ram dut (
        .clk(clk),
        .wr_en(wr_en),
        .addr(addr),
        .din(din),
        .dout(dout)
    );

    // Gerador de clock
    always #5 clk = ~clk;

    initial begin
        // Inicialização
        clk = 0; wr_en = 0; addr = 16'd0; din = 16'd0;
        #15;

       
        // TESTE 1: Escrever "42" (Hex: 002A) no Endereço 10
        // ==========================================
        addr = 16'd10;
        din = 16'h002A;
        wr_en = 1; // Manda gravar!
        #10;       // Espera a borda do clock
        wr_en = 0; // Tira o comando de gravação

        // ==========================================
        // TESTE 2: Escrever "99" (Hex: 0063) no Endereço 5
        // ==========================================
        addr = 16'd5;
        din = 16'h0063;
        wr_en = 1;
        #10;
        wr_en = 0;

        // ==========================================
        // TESTE 3: Ler os endereços e ver se ela lembra
        // ==========================================
        // Lendo o endereço 10 (dout deve mostrar 002A)
        addr = 16'd10;
        #10;

        // Lendo o endereço 5 (dout deve mostrar 0063)
        addr = 16'd5;
        #10;
        
        // Lendo um endereço vazio, por exemplo 8 (dout deve mostrar 0000)
        addr = 16'd8;
        #10;

        $display("Fim dos testes da RAM!");
        $finish;
    end

endmodule
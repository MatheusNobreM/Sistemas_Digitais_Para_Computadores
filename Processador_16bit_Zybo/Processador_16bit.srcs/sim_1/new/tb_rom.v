`timescale 1ns / 1ps

module tb_rom();

    reg         clk;
    reg         en;
    reg  [15:0] addr;
    wire [15:0] dout;

    
    rom dut (
        .clk(clk),
        .en(en),
        .addr(addr),
        .dout(dout)
    );

    always begin
        #5 clk = ~clk;
    end

    initial begin
        
        clk = 0;
        en = 0;       // Começa com a ROM desativada
        addr = 16'd0;
        
        #15;          // Espera inicial para estabilizar

        // --- TESTE 1: Ler endereço 0 com a ROM DESABILITADA ---
        addr = 16'd0;
        #10;          // O sinal dout não deve carregar a instrução ainda

        // --- TESTE 2: Habilitar a ROM e ler a posição 0 (MOV R1, #42) ---
        en = 1;       // Ativa a ROM
        #10;          // Na próxima borda, dout deve mostrar a instrução do endereço 0

        // --- TESTE 3: Ler a posição 2 (MOV R2, #10) ---
        addr = 16'd2;
        #10;          // Avança um ciclo de clock

        // --- TESTE 4: Ler a posição 4 (ADD R3, R1, R2) ---
        addr = 16'd4;
        #10;

        // --- TESTE 5: Ler a posição 6 (HALT) ---
        addr = 16'd6;
        #10;

        // --- TESTE 6: Desabilitar a ROM e mudar o endereço ---
        // O dado na saída deve congelar ou ignorar o novo endereço
        en = 0;
        addr = 16'd0;
        #10;

        $display("Fim dos testes da ROM!");
        $finish;
    end

endmodule
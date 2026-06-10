`timescale 1ns / 1ps

module rom (
    input  wire        clk,
    input  wire        en,
    input  wire [15:0] addr, 
    output reg  [15:0] dout
); // <-- CORREÇÃO 1: Ponto e vírgula adicionado aqui

    reg [15:0] memoria [0:255];

    integer i;
    
    initial begin
        // Zera toda a memória por segurança
        for (i = 0; i < 256; i = i + 1) begin
            memoria[i] = 16'd0;
        end

        // ==========================================
        // 1. LEITURA DO EXTERIOR
        // ==========================================
        // [0] IN R1 (Lê a porta externa e guarda em R1 - iterações do loop)
        memoria[0] = 16'b11110_001_000000_01; 

        // [2] MOV R2, #0 (Fibonacci N-2)
        memoria[2] = 16'b00011_010_00000000; 

        // [4] MOV R3, #1 (Fibonacci N-1)
        memoria[4] = 16'b00011_011_00000001; 

        // [6] MOV R7, #0 (Valor zero para comparação)
        memoria[6] = 16'b00011_111_00000000; 

        // ==========================================
        // 2. USO DA PILHA
        // ==========================================
        // [8] PSH R2 (Empilha 0)
        memoria[8] = 16'b00000_000_010_000_01; 

        // [10] PSH R3 (Empilha 1)
        memoria[10] = 16'b00000_000_011_000_01;

        // ==========================================
        // 3. INÍCIO DO LOOP (Endereço 12)
        // ==========================================
        // [12] CMP R1, R7 (Verifica se R1 chegou a zero)
        memoria[12] = 16'b00000_000_001_111_11; 

        // [14] JEQ +18 (Se R1 == 0, desvia para o endereço 34 fora do loop)
        memoria[14] = 16'b00001_000010010_01; 

        // --- CÁLCULO DE FIBONACCI ---
        // [16] POP R3 (Desempilha N-1)
        memoria[16] = 16'b00000_011_000_000_10; 

        // [18] POP R2 (Desempilha N-2)
        memoria[18] = 16'b00000_010_000_000_10; 

        // [20] ADD R4, R2, R3 (Próximo termo da sequência)
        memoria[20] = 16'b01000_100_010_011_00; 

        // [22] SHL R5, R4, #1 (Deslocamento lógico para a esquerda)
        memoria[22] = 16'b11000_101_100_00001;

        // --- PREPARA PRÓXIMA ITERAÇÃO ---
        // [24] PSH R3 (O antigo N-1 se torna o novo N-2)
        memoria[24] = 16'b00000_000_011_000_01; 

        // [26] PSH R4 (A nova soma se torna o novo N-1)
        memoria[26] = 16'b00000_000_100_000_01; 

        // [28] MOV R6, #1 (Passo de decremento)
        memoria[28] = 16'b00011_110_00000001; 
        
        // [30] SUB R1, R1, R6 (Decrementa o contador de iterações)
        memoria[30] = 16'b01010_001_001_110_00; 

        // [32] JMP -22 (Retorna para o CMP no endereço 12)
        memoria[32] = 16'b00001_111101010_00; 

        // ==========================================
        // 4. FINALIZAÇÃO E SAÍDA EXTERNA (Endereço 34)
        // ==========================================
        // [34] POP R4 (Recupera o último valor calculado na pilha)
        memoria[34] = 16'b00000_100_000_000_10;

        // [36] OUT R4 (Escreve o resultado na porta de saída)
        memoria[36] = 16'b11110_000_100_000_10; 

        // [38] HALT (Finaliza o processamento)
        memoria[38] = 16'b11111_000_00000000; 
    end

    // ==========================================
    // LÓGICA DE LEITURA ASSÍNCRONA
    // ==========================================
    always @(*) begin
        if (en) begin
            dout = memoria[addr[7:0]];
        end else begin
            dout = 16'd0;
        end
    end
    
// <-- CORREÇÃO 2: 'end' e 'endmodule' devidamente separados
endmodule
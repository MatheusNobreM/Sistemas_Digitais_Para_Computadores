`timescale 1ns / 1ps

module ram (
    input  wire        clk,
    input  wire        wr_en,    // Habilita a escrita (Write Enable)
    input  wire [15:0] addr,     // Endereço de memória
    input  wire [15:0] din,      // Dado de entrada (para salvar na memória)
    output wire [15:0] dout      // Dado de saída (lido da memória)
);

    // Declara uma memória de 256 posições de 16 bits
    reg [15:0] memoria [0:255];

    // Opcional: Inicializar a RAM com zeros para o gráfico de simulação ficar limpo
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            memoria[i] = 16'd0;
        end
    end

    // ==========================================
    // ESCRITA SÍNCRONA
    // ==========================================
    // Só grava o dado na borda de subida do clock SE o wr_en estiver em 1
    always @(posedge clk) begin
        if (wr_en) begin
            memoria[addr[7:0]] <= din;
        end
    end

    // ==========================================
    // LEITURA ASSÍNCRONA (Combinacional)
    // ==========================================
    // A saída mostra continuamente o que está no endereço selecionado
    assign dout = memoria[addr[7:0]];

endmodule
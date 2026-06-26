`timescale 1ns / 1ps
// Memoria de dados/programa - versao SINTETIZAVEL (sem tri-state).
//   - leitura combinacional  (data_out = ram[addr])
//   - escrita sincrona        (if wr: ram[addr] <= data_in)
module memory_inst #(
    parameter ADDR_WIDTH = 5,
    parameter DATA_WIDTH = 8
) (
    input  wire                  clk,
    input  wire                  wr,
    input  wire [ADDR_WIDTH-1:0] addr,
    input  wire [DATA_WIDTH-1:0] data_in,
    output wire [DATA_WIDTH-1:0] data_out
);

    reg [DATA_WIDTH-1:0] ram [0:(1<<ADDR_WIDTH)-1];

    // =====================================================================
    //  PROGRAMA (assembly desta ISA acumuladora) - palavra de 8 bits
    //  Formato:  [7:5]=opcode (3 bits)   [4:0]=endereco (5 bits)
    //  Opcodes: 0=HLT 1=LDA 2=STA 3=ADD 4=SUB 5=AND 6=JMP 7=JZ
    //
    //  I/O mapeado em memoria (enderecos cabem em 5 bits):
    //     0x1E -> CHAVES (entrada / switches)
    //     0x1F -> LEDS   (saida)
    //
    //  Amostra unica (sob comando do reset / BTN0):
    //    ao SAIR do reset, le as chaves UMA vez, copia para os LEDs e PARA (HLT).
    //    Os LEDs ficam congelados nesse valor. Mexer nas chaves NAO muda nada.
    //    Para carregar um novo valor: ajuste as chaves e aperte o reset (BTN0)
    //    de novo -> ao sair do reset ele re-amostra.
    //  -> os LEDs sao controlados pelo processador executando o programa.
    // =====================================================================
    integer i;
    initial begin
        for (i = 0; i < (1<<ADDR_WIDTH); i = i + 1)
            ram[i] = {DATA_WIDTH{1'b0}};

        ram[0] = 8'h3E; // LDA 0x1E  (001_11110) ; AC  = chaves
        ram[1] = 8'h5F; // STA 0x1F  (010_11111) ; LEDs = AC
        ram[2] = 8'h00; // HLT       (000_00000) ; para -> so o reset re-amostra

    end

    always @(posedge clk) begin
        if (wr)
            ram[addr] <= data_in;
    end

    assign data_out = ram[addr];

endmodule

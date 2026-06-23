`timescale 1ns / 1ps
// Memoria de dados/programa - versao SINTETIZAVEL (sem tri-state).
//   - leitura combinacional  (data_out = ram[addr])
//   - escrita sincrona        (if wr: ram[addr] <= data_in)
module memory_inst #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 16
) (
    input  wire                  clk,
    input  wire                  wr,
    input  wire [ADDR_WIDTH-1:0] addr,
    input  wire [DATA_WIDTH-1:0] data_in,
    output wire [DATA_WIDTH-1:0] data_out
);

    reg [DATA_WIDTH-1:0] ram [0:(1<<ADDR_WIDTH)-1];

    // =====================================================================
    //  PROGRAMA (assembly desta ISA acumuladora)
    //  Formato: [15:12]=opcode  [7:0]=endereco
    //  Opcodes: 1=LDA 2=STA 3=ADD 4=SUB 5=AND 6=JMP 7=JZ F=HLT
    //
    //  I/O mapeado em memoria:
    //     0xF0 -> CHAVES (entrada / switches)
    //     0xF1 -> LEDS   (saida)
    //
    //  Loop: le as chaves e copia para os LEDs, eternamente.
    //  -> os LEDs sao controlados pelo processador executando o programa.
    // =====================================================================
    integer i;
    initial begin
        for (i = 0; i < (1<<ADDR_WIDTH); i = i + 1)
            ram[i] = {DATA_WIDTH{1'b0}};

        ram[0] = 16'h10F0; // LDA 0xF0   ; AC = chaves
        ram[1] = 16'h20F1; // STA 0xF1   ; LEDs = AC
        ram[2] = 16'h6000; // JMP 0      ; repete

    end

    always @(posedge clk) begin
        if (wr)
            ram[addr] <= data_in;
    end

    assign data_out = ram[addr];

endmodule

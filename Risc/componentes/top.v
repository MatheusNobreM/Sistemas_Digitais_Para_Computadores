`timescale 1ns / 1ps
// =====================================================================
//  TOP-LEVEL para a placa ZYBO (Rev B)
//  Os LEDs sao controlados pelo PROCESSADOR executando o programa (assembly).
//
//    clk -> clock de 125 MHz da placa
//    rst -> BTN0 (reset do processador, ativo em alto)
//    sw  -> chaves SW0..SW3  (entrada lida via "LDA 0x1E")
//    led -> LD0..LD3         (saida escrita via "STA 0x1F")
//
//  Programa atual: LDA chaves -> STA leds -> HLT
//  (amostra unica: ao sair do reset le as chaves, mostra nos LEDs e para.
//   Para carregar um novo valor, ajuste as chaves e aperte o reset BTN0.)
// =====================================================================
module top (
    input  wire       clk,
    input  wire       rst,        // BTN0
    input  wire [3:0] sw,
    output wire [3:0] led
);

    wire [7:0] in_port;
    wire [7:0] out_port;
    wire       halt;

    assign in_port = {4'd0, sw};    // chaves nos 4 bits baixos da entrada
    assign led     = out_port[3:0]; // 4 bits baixos da saida nos LEDs

    cpu_top #(
        .DATA_WIDTH(8),
        .ADDR_WIDTH(5),
        .OPCODE_WIDTH(3)
    ) cpu (
        .clk(clk),
        .rst(rst),
        .in_port(in_port),
        .out_port(out_port),
        .halt_out(halt)
    );

endmodule

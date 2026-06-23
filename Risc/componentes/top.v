`timescale 1ns / 1ps
// =====================================================================
//  TOP-LEVEL para a placa ZYBO (Rev B)
//  Os LEDs sao controlados pelo PROCESSADOR executando o programa (assembly).
//
//    clk -> clock de 125 MHz da placa
//    rst -> BTN0 (reset do processador, ativo em alto)
//    sw  -> chaves SW0..SW3  (entrada lida via "LDA 0xF0")
//    led -> LD0..LD3         (saida escrita via "STA 0xF1")
//
//  Programa atual: loop  LDA chaves -> STA leds -> JMP 0
//  (os LEDs seguem as chaves, mas passando pelo processador)
// =====================================================================
module top (
    input  wire       clk,
    input  wire       rst,        // BTN0
    input  wire [3:0] sw,
    output wire [3:0] led
);

    wire [15:0] in_port;
    wire [15:0] out_port;
    wire        halt;

    assign in_port = {12'd0, sw};   // chaves nos 4 bits baixos da entrada
    assign led     = out_port[3:0]; // 4 bits baixos da saida nos LEDs

    cpu_top #(
        .DATA_WIDTH(16),
        .ADDR_WIDTH(8),
        .OPCODE_WIDTH(4)
    ) cpu (
        .clk(clk),
        .rst(rst),
        .in_port(in_port),
        .out_port(out_port),
        .halt_out(halt)
    );

endmodule

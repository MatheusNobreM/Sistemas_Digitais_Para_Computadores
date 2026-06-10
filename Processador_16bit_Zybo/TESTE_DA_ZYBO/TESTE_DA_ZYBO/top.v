`timescale 1ns / 1ps

module top (
    input  wire       clk,
    input  wire [3:0] btn,
    input  wire [3:0] sw,
    output wire [3:0] led
);

    wire [15:0] in_port;
    wire [15:0] out_port;

    assign in_port = {12'd0, sw};
    assign led = out_port[3:0];

    processador_top u_processador (
        .clk(clk),
        .rst(btn[0]),
        .in_port(in_port),
        .out_port(out_port)
    );

endmodule

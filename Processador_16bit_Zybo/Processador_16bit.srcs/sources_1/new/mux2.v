`timescale 1ns / 1ps

module mux2 (
    input  wire [15:0] I0,
    input  wire [15:0] I1,
    input  wire        sel,
    output wire [15:0] out
);

    // Se sel for 1, a saída recebe I1. Se for 0, recebe I0.
    assign out = sel ? I1 : I0; 

endmodule
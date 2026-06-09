`timescale 1ns / 1ps

module mux4 (
    input  wire [15:0] I0,
    input  wire [15:0] I1,
    input  wire [15:0] I2,
    input  wire [15:0] I3,
    input  wire [1:0]  sel, // Seletor de 2 bits
    output reg  [15:0] out
);

    always @(*) begin
        case (sel)
            2'b00: out = I0;
            2'b01: out = I1;
            2'b10: out = I2;
            2'b11: out = I3;
            default: out = 16'd0; // Proteção contra criação de latches indesejados
        endcase
    end

endmodule
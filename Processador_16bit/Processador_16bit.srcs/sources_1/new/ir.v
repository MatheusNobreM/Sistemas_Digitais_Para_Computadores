`timescale 1ns / 1ps



module ir(
input wire clk,
input wire rst,
input wire ld, // ir load do diagrama
input wire [15:0] D, // vem da room

output reg [15:0] Q
);

always @(posedge clk or posedge rst) begin

if (rst) begin
    Q <= 16'd0;
    end else if (ld) begin
        Q <= D; // guarda a instrução
        end
   end
   
   
endmodule
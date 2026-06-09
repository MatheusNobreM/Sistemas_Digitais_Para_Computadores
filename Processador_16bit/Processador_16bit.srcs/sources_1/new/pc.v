`timescale 1ns / 1ps

module pc(
input wire clk,
input wire rst,
input wire PC_clr,
input wire PC_inc,
input wire ld,
input wire [15:0] D,
output reg [15:0] Q
);

always @(posedge clk or posedge rst ) begin

    if (rst || PC_clr) begin
        Q <= 16'd0;
    end else if (ld) begin
        Q <= D; // seria um branch ou jump
    end else if (PC_inc) begin
        Q <= Q + 16'd2; // prox instrução
    end
   end

endmodule


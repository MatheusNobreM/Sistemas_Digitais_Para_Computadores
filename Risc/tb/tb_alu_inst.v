`timescale 1ns / 1ps
module tb_alu_inst();
    reg [15:0] ac_out, data;
    reg [3:0] opcode;
    wire [15:0] alu_out;
    wire zero;

    alu_inst #(16, 4) dut (.ac_out(ac_out), .data(data), .opcode(opcode), .alu_out(alu_out), .zero(zero));

    initial begin
        ac_out = 16'd10; data = 16'd5;
        
        opcode = 4'b0011; #10; // Testa ADD: Deve dar 15
        opcode = 4'b0100; #10; // Testa SUB: Deve dar 5
        opcode = 4'b0101; #10; // Testa AND: 10 & 5 = 0
        
        // Testa a flag Zero
        ac_out = 16'd7; data = 16'd7; opcode = 4'b0100; #10; // 7 - 7 = 0 (Flag zero deve subir)
        
        $finish;
    end
endmodule
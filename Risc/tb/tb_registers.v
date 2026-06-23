`timescale 1ns / 1ps
module tb_registers();
    reg clk, rst, ld_ac, ld_ir;
    reg [15:0] alu_out, data_bus;
    
    wire [15:0] ac_out;
    wire [3:0] opcode;
    wire [7:0] ir_addr;

    register_ac #(16) dut_ac (.clk(clk), .rst(rst), .ld_ac(ld_ac), .alu_out(alu_out), .ac_out(ac_out));
    register_ir #(16, 4, 8) dut_ir (.clk(clk), .rst(rst), .ld_ir(ld_ir), .data(data_bus), .opcode(opcode), .ir_addr(ir_addr));

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; ld_ac = 0; ld_ir = 0; alu_out = 16'hFFFF; data_bus = 16'h300A; #10;
        rst = 0;
        
        ld_ac = 1; ld_ir = 1; #10; // Grava os valores. AC = FFFF. IR extrai Opcode=3 e Addr=0A.
        ld_ac = 0; ld_ir = 0; alu_out = 16'h0000; data_bus = 16'h0000; #10; // Tira os loads, os valores devem se manter congelados nas saídas.
        
        $finish;
    end
endmodule

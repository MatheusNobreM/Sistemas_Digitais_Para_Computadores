`timescale 1ns / 1ps
module tb_counter_pc();
    reg clk, rst, ld_pc, inc_pc;
    reg [7:0] ir_addr;
    wire [7:0] pc_addr;

    counter_pc #(8) dut (.clk(clk), .rst(rst), .ld_pc(ld_pc), .inc_pc(inc_pc), .ir_addr(ir_addr), .pc_addr(pc_addr));

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; ld_pc = 0; inc_pc = 0; ir_addr = 8'hAA; #10;
        
        rst = 0; inc_pc = 1; #20; // Deixa contar por 2 ciclos (Deve ir para 01, 02)
        
        inc_pc = 0; ld_pc = 1; #10; // Testa Salto: Deve ir para AA
        
        ld_pc = 0; inc_pc = 1; #10; // Continua contando: Deve ir para AB
        
        $finish;
    end
endmodule
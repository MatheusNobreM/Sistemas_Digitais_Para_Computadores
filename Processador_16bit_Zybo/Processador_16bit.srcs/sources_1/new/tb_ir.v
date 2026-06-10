`timescale 1ns / 1ps

module tb_ir();

reg clk;
reg rst;
reg ld;
reg [15:0] D;
wire [15:0] Q;

ir dut (
.clk(clk),
.rst(rst),
.ld(ld),
.D(D),
.Q(Q)
);


always begin
        #5 clk = ~clk;
    end
    
    
initial begin

clk = 0;
rst = 1;
ld = 0;
D = 16'd0;

#15

rst = 0;

#5;

D = 16'b0101_0101_1010_1010;

//  Carregar a instrução
ld = 1;
 #10; // Agora Q deve assumir o valor de D
        
 // Tira o load. O IR deve segurar o valor mesmo que D mude
ld = 0;
D = 16'hFFFF; 
#10; // Q deve se manter com o valor antigo (0101_0101_1010_1010)

       $display("Fim dos testes do IR!");
        $finish;
    end

endmodule
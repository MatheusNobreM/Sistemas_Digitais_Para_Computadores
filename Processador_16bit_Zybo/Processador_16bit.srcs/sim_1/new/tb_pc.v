`timescale 1ns / 1ps


module tb_pc();

reg  clk;
reg  rst;
reg  PC_clr;
reg  PC_inc;
reg  ld;
reg  [15:0] D;

wire [15:0] Q;

pc dut(
.clk(clk),
.rst(rst),
.PC_clr(PC_clr),
.PC_inc(PC_inc),
.ld(ld),
.D(D),
.Q(Q)
);

always begin
   #5 clk = ~clk;
end


initial begin
        // Inicialização
clk = 0;
rst = 1;
PC_clr = 0; PC_inc = 0; ld = 0; D = 16'd0;
        
#15; // Espera o reset agir
rst = 0;
#5;

 // TESTE 1: Incrementar o PC (Deve ir de 0 para 2)
PC_inc = 1;
#10;
        
// Deve ir de 2 para 4
#10; 
        
PC_inc = 0; // Para de incrementar (Q deve se manter em 4)
#10;

        // Carregar um valor (Simulando um salto/Branch)
ld = 1;
D = 16'd50; // Manda o PC para o endereço 50
#10;
ld = 0; // Tira o comando de carga
#10;

        // TESTE 3: Incrementar a partir do novo valor (50 -> 52)
PC_inc = 1;
#10;
PC_inc = 0;
#10;

 // TESTE 4: Limpar o PC (Clear síncrono)
PC_clr = 1;
#10; // Q deve voltar para 0
        
PC_clr = 0;
#10;

        $display("Fim dos testes do PC!");
        $finish;
    end

endmodule



`timescale 1ns / 1ps


module tb_register_file();

// tem que começar declarando os sinais do testbench

    reg clk;
    reg rst;
    reg [2:0]Rd_sel;
    reg Rd_wr;
    reg [15:0] Rd_data;
    reg [2:0] Rm_sel;
    reg [2:0] Rn_sel;
    
    
    wire [15:0] Rm;
    wire [15:0] Rn;
    

register_file dut(
.clk(clk),
.rst(rst),
.Rd_sel(Rd_sel),
.Rd_wr(Rd_wr),
.Rd_data(Rd_data),
.Rm_sel(Rm_sel),
.Rn_sel(Rn_sel),
.Rm(Rm),
.Rn(Rn)
);


// Gerador de Clock
 // Este bloco fica invertendo o sinal do clock a cada 5ns Isso cria um clock com período total de 10ns (frequência de 100MHz).
    always begin
        #5 clk = ~clk;
    end
    
    

// 4. Geração de Estímulos

initial begin

    // inicalizaqção dos sinais
    
 clk = 0;
 rst = 1;
 Rd_sel = 0; Rd_wr = 0; Rd_data = 0;
 Rm_sel = 0; Rn_sel = 0;
 
 #15; // 15ns pra dar tempo, garante uma borda de subida com reset ativo
 
 rst = 0;
#5;

// o teste vai consistir em escrever valores e ler eles dos registradores do banco

// escrevo 42 em R1

Rd_sel = 3'd1; // aqui eu seleciono R1
Rd_data = 16'd42; // valor 42 pra salvar
Rd_wr = 1; // manter escrita habilitada
#10;

//Eeescrever o valor 100 no Registrador R5
Rd_sel = 3'd5;        
Rd_data = 16'd100;    
Rd_wr = 1;           
#10;

Rd_wr = 0; // desabilita escrita para garantir que os dados não vao ser modificados
#10;

// agora para ler, tentar ler o R1 e r5 ao mesmo tempo

Rm_sel = 3'd1; // aponta para R1, teria que mostrar 42
Rn_sel = 3'd5; // para R5

#10;

// testar se a leitura zera ao apontar para outro registrador vazio
Rm_sel = 3'd2;        // R2 nunca foi escrito, deve mostrar 0
#10;

$display("Fim dos testes do Register File!");
        $finish;
    end

endmodule

    











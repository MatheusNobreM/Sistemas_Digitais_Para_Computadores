`timescale 1ns / 1ps

module tb_mux4();

    reg  [15:0] I0;
    reg  [15:0] I1;
    reg  [15:0] I2;
    reg  [15:0] I3;
    reg  [1:0]  sel;
    
    wire [15:0] out;

    mux4 dut (
        .I0(I0),
        .I1(I1),
        .I2(I2),
        .I3(I3),
        .sel(sel),
        .out(out)
    );

    initial begin
        // Valores fixos nas entradas para facilitar a visualização no gráfico
        I0 = 16'h1111;
        I1 = 16'h2222;
        I2 = 16'h3333;
        I3 = 16'h4444;
        
        // TESTE 1: Seleciona I0
        sel = 2'b00; 
        #10;
        
        // TESTE 2: Seleciona I1
        sel = 2'b01; 
        #10;
        
        // TESTE 3: Seleciona I2
        sel = 2'b10; 
        #10;
        
        // TESTE 4: Seleciona I3
        sel = 2'b11; 
        #10;
        
        $display("Fim dos testes do MUX 4x1!");
        $finish;
    end

endmodule
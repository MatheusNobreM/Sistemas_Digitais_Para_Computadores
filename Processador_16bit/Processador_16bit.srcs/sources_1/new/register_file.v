`timescale 1ns / 1ps

module register_file(

input wire clk,
input wire rst,

//portas de escrita

input wire [2:0] Rd_sel,
input wire Rd_wr,
input wire [15:0] Rd_data,


//portas de leitura

input wire [2:0] Rm_sel,
input wire [2:0] Rn_sel,

output wire [15:0] Rm, // A e B da ula
output wire [15:0] Rn
);

// array que vai ser a declaração da memoria interna

reg [15:0] reg_array [0:7];

integer i; // pro for de reset


// LEITURA (Combinacional / Assíncrona)
    // --------------------------------------------------------
    // A leitura não depende do clock. Assim que o endereço (Rm_sel ou Rn_sel) 
    // muda, a saída é atualizada imediatamente.
    
    
assign Rm = reg_array[Rm_sel];
assign Rn = reg_array[Rn_sel];

// ESCRITA (Síncrona)
    // --------------------------------------------------------
    // A escrita só acontece na borda de subida do clock (posedge clk).
    
    
    
  always@(posedge clk or posedge rst) begin
  
    if (rst) begin
        // se rst for acionado, zera os 8 registradores
        
        for(i = 0; i < 8; i = i + 1) begin
            reg_array[i] <= 16'd0;
        end
    end else if (Rd_wr) begin
        // Se o write tiver ativo, salva o dado no registrador escolhido
        reg_array[Rd_sel] <= Rd_data;
    end
    end
    
    endmodule
    
    
    












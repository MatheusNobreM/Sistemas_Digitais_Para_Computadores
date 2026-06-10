`timescale 1ns / 1ps

module ula (
    input  wire [15:0] A,     // Entrada A (vem de Rm)
    input  wire [15:0] B,     // Entrada B (vem de Rn)
    input  wire [4:0]  shamt, // <-- NOVO: Valor do Shift (vem do Imediato da instrução)
    input  wire [3:0]  op,    // Seletor de operação da FSM
    output reg  [15:0] Q,     // Resultado dos cálculos
    output reg         Z,     // Flag Zero (1 se A == B)
    output reg         C      // Flag Carry/Menor (1 se A < B)
);

    always @(*) begin
        // Para evitar os latches
        Z = 1'b0;
        C = 1'b0;

        case (op)
            4'b0000: Q = A;         // PASS A
            4'b0100: Q = A + B;     // ADD 
            4'b0101: Q = A - B;     // SUB 
            4'b0110: Q = A * B;     // MUL 
            4'b0111: Q = A & B;     // AND Lógico
            4'b1000: Q = A | B;     // OR Lógico
            4'b1001: Q = ~A;        // NOT 
            4'b1010: Q = A ^ B;     // XOR Lógico
            
            4'b1011: begin          // CMP
                Q = 16'd0;          
                Z = (A == B) ? 1'b1 : 1'b0; 
                C = (A < B)  ? 1'b1 : 1'b0; 
            end

            
            // SHIFTS E ROTAÇÕES 
            4'b1100: Q = A << shamt;           // SHL (Desloca para a esquerda pelo imediato)
            
            4'b1101: Q = A >> shamt;           // SHR (Desloca para a direita pelo imediato)
            
            4'b1110: Q = (A << 1) | (A >> 15); // ROL (Rotaciona 1 bit para a esquerda)
            
            4'b1111: Q = (A >> 1) | (A << 15); // ROR (Rotaciona 1 bit para a direita)

            default: Q = 16'd0;     // Prevenção
        endcase
    end

endmodule
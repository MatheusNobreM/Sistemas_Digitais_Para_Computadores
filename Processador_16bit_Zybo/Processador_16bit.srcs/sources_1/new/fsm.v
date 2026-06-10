`timescale 1ns / 1ps

module fsm (
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] IR_data,
    input  wire        flag_Z,    
    input  wire        flag_C,    

    output reg         ROM_en,
    output reg         PC_clr,
    output reg         PC_inc,
    output reg         PC_ld,
    output reg         IR_load,
    output reg  [15:0] Immed,
    output reg  [1:0]  RF_sel,
    output reg  [2:0]  Rd_sel,
    output reg         Rd_wr,
    output reg         RAM_wr,
    output reg  [2:0]  Rm_sel,
    output reg  [2:0]  Rn_sel,
    output reg  [3:0]  ula_op,
    output reg         Flags_wr,
    output reg         SP_inc,
    output reg         SP_dec,
    output reg         addr_sel,
    output reg         out_wr     // <-- NOVO: Permissão para escrever na porta OUT
);

    parameter FETCH   = 2'b00;
    parameter EXECUTE = 2'b01;
    parameter HALT_ST = 2'b10;

    reg [1:0] state, next_state;
    wire [4:0] opcode = IR_data[15:11];

    always @(posedge clk or posedge rst) begin
        if (rst) state <= FETCH;
        else     state <= next_state;
    end

    always @(*) begin
        ROM_en   = 0; PC_clr   = 0; PC_inc   = 0; PC_ld    = 0; IR_load  = 0;
        Immed    = 16'd0; RF_sel   = 2'b00; Rd_wr    = 0; RAM_wr   = 0; 
        ula_op   = 4'b0000; Flags_wr = 0; SP_inc   = 0; SP_dec   = 0; addr_sel = 0;
        out_wr   = 0; // Padrão é não escrever na porta
        
        Rd_sel   = IR_data[10:8]; 
        Rm_sel   = IR_data[7:5];  
        Rn_sel   = IR_data[4:2];  
        
        next_state = state;

        case (state)
            FETCH: begin
                ROM_en  = 1;
                IR_load = 1;
                PC_inc  = 1;
                next_state = EXECUTE;
            end

            EXECUTE: begin
                case (opcode)
                    5'b00000: begin // CMP, PSH, POP, NOP
                        case (IR_data[1:0])
                            2'b11: begin ula_op = 4'b1011; Flags_wr = 1; end
                            2'b01: begin addr_sel = 1; RAM_wr = 1; SP_dec = 1; end
                            2'b10: begin SP_inc = 1; addr_sel = 1; RF_sel = 2'b01; Rd_wr = 1; end
                        endcase
                        next_state = FETCH;
                    end

                    5'b00001: begin // JUMPS
                        Immed = {{7{IR_data[10]}}, IR_data[10:2]}; 
                        case (IR_data[1:0])
                            2'b00: PC_ld = 1;
                            2'b01: if (flag_Z == 1 && flag_C == 0) PC_ld = 1;
                            2'b10: if (flag_Z == 0 && flag_C == 1) PC_ld = 1;
                            2'b11: if (flag_Z == 0 && flag_C == 0) PC_ld = 1;
                        endcase
                        next_state = FETCH;
                    end

                    5'b00010: begin ula_op = 4'b0000; RF_sel = 2'b00; Rd_wr = 1; next_state = FETCH; end // MOV Rd, Rm
                    5'b00011: begin Immed = {8'd0, IR_data[7:0]}; RF_sel = 2'b10; Rd_wr = 1; next_state = FETCH; end // MOV Rd, #Im
                    5'b00100: begin RAM_wr = 1; next_state = FETCH; end // STR
                    5'b00110, 5'b00111: begin RF_sel = 2'b01; Rd_wr = 1; next_state = FETCH; end // LDR

                    5'b01000, 5'b01001: begin ula_op = 4'b0100; RF_sel = 2'b00; Rd_wr = 1; next_state = FETCH; end // ADD
                    5'b01010, 5'b01011: begin ula_op = 4'b0101; RF_sel = 2'b00; Rd_wr = 1; next_state = FETCH; end // SUB
                    5'b01100, 5'b01101: begin ula_op = 4'b0110; RF_sel = 2'b00; Rd_wr = 1; next_state = FETCH; end // MUL
                    5'b01110, 5'b01111: begin ula_op = 4'b0111; RF_sel = 2'b00; Rd_wr = 1; next_state = FETCH; end // AND
                    5'b10000, 5'b10001: begin ula_op = 4'b1000; RF_sel = 2'b00; Rd_wr = 1; next_state = FETCH; end // ORR
                    5'b10010, 5'b10011: begin ula_op = 4'b1001; RF_sel = 2'b00; Rd_wr = 1; next_state = FETCH; end // NOT
                    5'b10100, 5'b10101: begin ula_op = 4'b1010; RF_sel = 2'b00; Rd_wr = 1; next_state = FETCH; end // XOR

                    5'b10110, 5'b10111: begin ula_op = 4'b1101; RF_sel = 2'b00; Rd_wr = 1; next_state = FETCH; end // SHR 
                    5'b11000, 5'b11001: begin ula_op = 4'b1100; RF_sel = 2'b00; Rd_wr = 1; next_state = FETCH; end // SHL 
                    5'b11010, 5'b11011: begin ula_op = 4'b1111; RF_sel = 2'b00; Rd_wr = 1; next_state = FETCH; end // ROR 
                    5'b11100, 5'b11101: begin ula_op = 4'b1110; RF_sel = 2'b00; Rd_wr = 1; next_state = FETCH; end // ROL 

                    // ==========================================
                    // ENTRADA, SAÍDA E HALT (Opcodes 11110 e 11111)
                    // ==========================================
                    5'b11110, 5'b11111: begin 
                        if (opcode == 5'b11111) begin 
                            next_state = HALT_ST; // HALT corrigido (lê apenas os 5 bits)
                        end
                        else if (IR_data[1:0] == 2'b01) begin 
                            // IN Rd (Opcode: 1111_...._...01)
                            RF_sel = 2'b11; // Canal 3 do MUX (in_port)
                            Rd_wr  = 1;
                            next_state = FETCH;
                        end
                        else if (IR_data[1:0] == 2'b10 && opcode == 5'b11110) begin 
                            // OUT Rm (Opcode: 11110_..._...10)
                            ula_op = 4'b0000; // ULA em PASS A
                            RF_sel = 2'b00;   // MUX pega da ULA
                            out_wr = 1;       // Grava na porta de saída externa
                            next_state = FETCH;
                        end
                        else begin 
                            // OUT #Im (Opcode: 11111)
                            // Junta Im[7:5] com Im[4:0] conforme a tabela
                            Immed  = {8'd0, IR_data[10:8], IR_data[4:0]}; 
                            RF_sel = 2'b10;   // MUX pega o Imediato
                            out_wr = 1;       // Grava na porta de saída externa
                            next_state = FETCH;
                        end
                    end

                    default: begin 
                        next_state = FETCH;
                    end
                endcase
            end

            HALT_ST: begin
                next_state = HALT_ST;
            end
        endcase
    end
endmodule
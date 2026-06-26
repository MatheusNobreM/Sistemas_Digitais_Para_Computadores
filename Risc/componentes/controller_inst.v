module controller_inst (
    input wire phase,
    input wire [2:0] opcode, // opcode de 3 bits (ir_reg[7:5])
    input wire zero,
    output reg rd, 
    output reg wr, 
    output reg ld_ir, 
    output reg ld_ac, 
    output reg ld_pc, 
    output reg inc_pc, 
    output reg halt, 
    output reg data_e, 
    output reg sel
);

    localparam OP_HLT = 3'b000; // HLT passou de 0xF para 0 (so cabem 8 codigos em 3 bits)
    localparam OP_LDA = 3'b001;
    localparam OP_STA = 3'b010;
    localparam OP_ADD = 3'b011;
    localparam OP_SUB = 3'b100;
    localparam OP_AND = 3'b101;
    localparam OP_JMP = 3'b110;
    localparam OP_JZ  = 3'b111;

    always @(*) begin
        rd = 0; wr = 0; ld_ir = 0; ld_ac = 0; 
        ld_pc = 0; inc_pc = 0; halt = 0; data_e = 0; sel = 0;

        if (phase == 1'b0) begin 
            sel = 0;      
            rd = 1;       
            ld_ir = 1;    
            inc_pc = 1;   
        end else begin 
            case (opcode)
                OP_LDA: begin sel = 1; rd = 1; ld_ac = 1; end
                OP_STA: begin sel = 1; data_e = 1; wr = 1; end
                OP_ADD: begin sel = 1; rd = 1; ld_ac = 1; end
                OP_SUB: begin sel = 1; rd = 1; ld_ac = 1; end
                OP_AND: begin sel = 1; rd = 1; ld_ac = 1; end
                OP_JMP: begin ld_pc = 1; end
                OP_JZ:  begin if (zero) ld_pc = 1; end
                OP_HLT: begin halt = 1; end
                default: ; 
            endcase
        end
    end

endmodule
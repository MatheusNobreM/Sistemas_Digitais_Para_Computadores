module controller_inst (
    input wire phase,        
    input wire [3:0] opcode, 
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

    localparam OP_LDA = 4'b0001;
    localparam OP_STA = 4'b0010;
    localparam OP_ADD = 4'b0011;
    localparam OP_SUB = 4'b0100;
    localparam OP_AND = 4'b0101;
    localparam OP_JMP = 4'b0110; 
    localparam OP_JZ  = 4'b0111; 
    localparam OP_HLT = 4'b1111; 

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
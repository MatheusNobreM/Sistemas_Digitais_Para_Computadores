module alu_inst #(
    parameter DATA_WIDTH = 8,
    parameter OPCODE_WIDTH = 3
) (
    input wire [DATA_WIDTH-1:0] ac_out,
    input wire [DATA_WIDTH-1:0] data,
    input wire [OPCODE_WIDTH-1:0] opcode,
    output reg [DATA_WIDTH-1:0] alu_out,
    output wire zero
);

    localparam OP_LDA = 3'b001;
    localparam OP_STA = 3'b010;
    localparam OP_ADD = 3'b011;
    localparam OP_SUB = 3'b100;
    localparam OP_AND = 3'b101;

    always @(*) begin
        case (opcode)
            OP_LDA: alu_out = data;            
            OP_STA: alu_out = ac_out;          
            OP_ADD: alu_out = ac_out + data;   
            OP_SUB: alu_out = ac_out - data;   
            OP_AND: alu_out = ac_out & data;   
            default: alu_out = ac_out;         
        endcase
    end

    assign zero = (alu_out == {DATA_WIDTH{1'b0}});

endmodule
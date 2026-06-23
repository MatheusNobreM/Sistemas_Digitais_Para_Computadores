module register_ir #(
    parameter DATA_WIDTH = 16,   
    parameter OPCODE_WIDTH = 4,  
    parameter ADDR_WIDTH = 8     
) (
    input wire clk,
    input wire rst,
    input wire ld_ir,
    input wire [DATA_WIDTH-1:0] data,
    output wire [OPCODE_WIDTH-1:0] opcode,
    output wire [ADDR_WIDTH-1:0] ir_addr
);

    reg [DATA_WIDTH-1:0] ir_reg;

    always @(posedge clk) begin
        if (rst) begin
            ir_reg <= {DATA_WIDTH{1'b0}};
        end else if (ld_ir) begin
            ir_reg <= data;
        end
    end

    assign opcode = ir_reg[DATA_WIDTH-1 : DATA_WIDTH-OPCODE_WIDTH];
    assign ir_addr = ir_reg[ADDR_WIDTH-1 : 0];

endmodule
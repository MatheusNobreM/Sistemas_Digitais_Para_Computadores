module register_ir #(
    parameter DATA_WIDTH = 8,    // palavra de 8 bits
    parameter OPCODE_WIDTH = 3,  // opcode em ir_reg[7:5]
    parameter ADDR_WIDTH = 5     // endereco em ir_reg[4:0]
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
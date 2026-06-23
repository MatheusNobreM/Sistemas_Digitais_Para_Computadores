module register_ac #(parameter DATA_WIDTH = 16) (
    input wire clk,
    input wire rst,
    input wire ld_ac,
    input wire [DATA_WIDTH-1:0] alu_out,
    output reg [DATA_WIDTH-1:0] ac_out
);

    always @(posedge clk) begin
        if (rst) begin
            ac_out <= {DATA_WIDTH{1'b0}}; 
        end else if (ld_ac) begin
            ac_out <= alu_out;            
        end
    end

endmodule
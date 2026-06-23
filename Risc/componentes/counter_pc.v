module counter_pc #(parameter ADDR_WIDTH = 8) (
    input wire clk,
    input wire rst,
    input wire ld_pc,
    input wire inc_pc,
    input wire [ADDR_WIDTH-1:0] ir_addr,
    output reg [ADDR_WIDTH-1:0] pc_addr
);

    always @(posedge clk) begin
        if (rst) begin
            pc_addr <= {ADDR_WIDTH{1'b0}}; 
        end else if (ld_pc) begin
            pc_addr <= ir_addr;            
        end else if (inc_pc) begin
            pc_addr <= pc_addr + 1;        
        end
    end

endmodule
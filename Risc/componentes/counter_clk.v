module counter_clk (
    input wire clk,
    input wire rst,
    input wire halt,  
    output reg phase
);

    always @(posedge clk) begin
        if (rst) begin
            phase <= 1'b0; 
        end else if (!halt) begin
            phase <= ~phase; 
        end
    end

endmodule
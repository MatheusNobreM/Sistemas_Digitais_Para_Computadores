module address_mux #(parameter ADDR_WIDTH = 5) (
    input wire [ADDR_WIDTH-1:0] pc_addr,
    input wire [ADDR_WIDTH-1:0] ir_addr,
    input wire sel,
    output wire [ADDR_WIDTH-1:0] addr
);

    assign addr = (sel) ? ir_addr : pc_addr;

endmodule
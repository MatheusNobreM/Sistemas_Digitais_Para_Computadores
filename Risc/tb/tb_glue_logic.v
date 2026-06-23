`timescale 1ns / 1ps
module tb_glue_logic();
    reg clk, rst, halt, sel, data_e;
    reg [7:0] pc_addr, ir_addr;
    reg [15:0] alu_out;
    
    wire phase;
    wire [7:0] mem_addr;
    wire [15:0] data_bus;

    counter_clk dut_clk (.clk(clk), .rst(rst), .halt(halt), .phase(phase));
    address_mux #(8) dut_mux (.pc_addr(pc_addr), .ir_addr(ir_addr), .sel(sel), .addr(mem_addr));
    driver_inst #(16) dut_driver (.alu_out(alu_out), .data_e(data_e), .data_bus(data_bus));

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; halt = 0; sel = 0; data_e = 0; 
        pc_addr = 8'h11; ir_addr = 8'h22; alu_out = 16'hBEEF; #10;
        
        rst = 0; #10; // Deixa o phase oscilar para 1
        
        sel = 1; data_e = 1; #10; // MUX deve passar 22. Driver deve passar BEEF.
        
        halt = 1; #20; // Clock das fases deve parar.
        
        $finish;
    end
endmodule
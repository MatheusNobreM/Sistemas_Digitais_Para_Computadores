`timescale 1ns / 1ps
module cpu_top #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 8,
    parameter OPCODE_WIDTH = 4
) (
    input  wire                  clk,
    input  wire                  rst,
    input  wire [DATA_WIDTH-1:0] in_port,    // CHAVES (entrada)
    output wire [DATA_WIDTH-1:0] out_port,   // LEDS   (saida)
    output wire                  halt_out
);

    // Enderecos de I/O mapeado em memoria
    localparam [ADDR_WIDTH-1:0] SW_ADDR  = 8'hF0;  // entrada (chaves)
    localparam [ADDR_WIDTH-1:0] LED_ADDR = 8'hF1;  // saida   (LEDs)

    wire [DATA_WIDTH-1:0] data_bus;
    wire [DATA_WIDTH-1:0] mem_dout;    // dado lido da RAM
    wire [DATA_WIDTH-1:0] read_data;   // dado lido (RAM ou porta de entrada)
    wire [ADDR_WIDTH-1:0] mem_addr, pc_addr, ir_addr;
    wire [DATA_WIDTH-1:0] ac_out, alu_out;

    wire [OPCODE_WIDTH-1:0] opcode;
    wire phase;
    wire zero;
    wire rd, wr, ld_ir, ld_ac, ld_pc, inc_pc, halt, data_e, sel;

    assign halt_out = halt;

    // ---- Entrada mapeada em memoria: ler do endereco SW_ADDR devolve as chaves
    assign read_data = (mem_addr == SW_ADDR) ? in_port : mem_dout;

    // ---- Saida mapeada em memoria: STA no endereco LED_ADDR atualiza os LEDs
    reg [DATA_WIDTH-1:0] out_reg;
    always @(posedge clk) begin
        if (rst)
            out_reg <= {DATA_WIDTH{1'b0}};
        else if (wr && (mem_addr == LED_ADDR))
            out_reg <= data_bus;
    end
    assign out_port = out_reg;

    counter_clk clk_gen (
        .clk(clk), .rst(rst), .halt(halt), .phase(phase)
    );

    controller_inst ctrl (
        .phase(phase), .opcode(opcode), .zero(zero), .rd(rd),
        .wr(wr), .ld_ir(ld_ir), .ld_ac(ld_ac), .ld_pc(ld_pc),
        .inc_pc(inc_pc), .halt(halt), .data_e(data_e), .sel(sel)
    );

    counter_pc #(ADDR_WIDTH) pc (
        .clk(clk), .rst(rst), .ld_pc(ld_pc), .inc_pc(inc_pc),
        .ir_addr(ir_addr), .pc_addr(pc_addr)
    );

    address_mux #(ADDR_WIDTH) mux (
        .pc_addr(pc_addr), .ir_addr(ir_addr), .sel(sel), .addr(mem_addr)
    );

    register_ir #(DATA_WIDTH, OPCODE_WIDTH, ADDR_WIDTH) ir (
        .clk(clk), .rst(rst), .ld_ir(ld_ir), .data(data_bus),
        .opcode(opcode), .ir_addr(ir_addr)
    );

    alu_inst #(DATA_WIDTH, OPCODE_WIDTH) alu (
        .ac_out(ac_out), .data(data_bus), .opcode(opcode),
        .alu_out(alu_out), .zero(zero)
    );

    register_ac #(DATA_WIDTH) ac (
        .clk(clk), .rst(rst), .ld_ac(ld_ac), .alu_out(alu_out), .ac_out(ac_out)
    );

    driver_inst #(DATA_WIDTH) driver (
        .alu_out(alu_out), .read_data(read_data), .data_e(data_e), .data_bus(data_bus)
    );

    memory_inst #(ADDR_WIDTH, DATA_WIDTH) mem (
        .clk(clk), .wr(wr), .addr(mem_addr),
        .data_in(data_bus), .data_out(mem_dout)
    );

endmodule

`timescale 1ns / 1ps
// Driver do barramento de dados - versao SINTETIZAVEL (mux 2:1).
//   - data_e=1 (STA): coloca alu_out (= acumulador) no barramento.
//   - data_e=0       : coloca o dado lido (read_data = RAM ou porta de entrada).
module driver_inst #(parameter DATA_WIDTH = 16) (
    input  wire [DATA_WIDTH-1:0] alu_out,
    input  wire [DATA_WIDTH-1:0] read_data,
    input  wire                  data_e,
    output wire [DATA_WIDTH-1:0] data_bus
);

    assign data_bus = (data_e) ? alu_out : read_data;

endmodule

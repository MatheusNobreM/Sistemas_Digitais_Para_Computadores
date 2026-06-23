`timescale 1ns / 1ps
module tb_controller_inst();
    reg phase, zero;
    reg [3:0] opcode;
    wire rd, wr, ld_ir, ld_ac, ld_pc, inc_pc, halt, data_e, sel;

    controller_inst dut (.phase(phase), .opcode(opcode), .zero(zero), .rd(rd), .wr(wr), .ld_ir(ld_ir), .ld_ac(ld_ac), .ld_pc(ld_pc), .inc_pc(inc_pc), .halt(halt), .data_e(data_e), .sel(sel));

    initial begin
        phase = 0; opcode = 4'b0000; zero = 0; #10; // Fase FETCH: rd, ld_ir, inc_pc devem ser 1
        
        phase = 1; opcode = 4'b0011; #10; // Fase EXEC (ADD): sel, rd, ld_ac devem ser 1
        phase = 1; opcode = 4'b0010; #10; // Fase EXEC (STA): sel, data_e, wr devem ser 1
        phase = 1; opcode = 4'b0111; zero = 1; #10; // Fase EXEC (JZ com zero=1): ld_pc deve ser 1
        
        $finish;
    end
endmodule
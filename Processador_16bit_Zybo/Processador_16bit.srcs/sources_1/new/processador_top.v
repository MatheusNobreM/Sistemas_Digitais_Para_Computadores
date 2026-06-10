`timescale 1ns / 1ps

module processador_top (
    input  wire        clk,
    input  wire        rst,
    // --- PORTAS FÍSICAS REAIS DO CHIP ---
    input  wire [15:0] in_port,
    output wire [15:0] out_port
);

    wire        w_ROM_en;
    wire        w_PC_clr;
    wire        w_PC_inc;
    wire        w_PC_ld;
    wire        w_IR_load;
    wire [15:0] w_Immed;
    wire [1:0]  w_RF_sel;
    wire [2:0]  w_Rd_sel;
    wire        w_Rd_wr;
    wire        w_RAM_wr;
    wire [2:0]  w_Rm_sel;
    wire [2:0]  w_Rn_sel;
    wire [3:0]  w_ula_op;
    
    wire w_flag_Z;
    wire w_flag_C;
    wire w_Flags_wr;

    wire w_SP_inc;
    wire w_SP_dec;
    wire w_addr_sel;
    
    wire w_out_wr; // Fio que avisa quando tem dado para a saída
    
    wire [15:0] w_IR_data;


    fsm inst_fsm (
        .clk(clk),
        .rst(rst),
        .IR_data(w_IR_data),      
        
        .ROM_en(w_ROM_en), .PC_clr(w_PC_clr), .PC_inc(w_PC_inc), .PC_ld(w_PC_ld),
        .IR_load(w_IR_load), .Immed(w_Immed), .RF_sel(w_RF_sel), .Rd_sel(w_Rd_sel),
        .Rd_wr(w_Rd_wr), .RAM_wr(w_RAM_wr), .Rm_sel(w_Rm_sel), .Rn_sel(w_Rn_sel),
        .ula_op(w_ula_op), .flag_Z(w_flag_Z), .flag_C(w_flag_C), .Flags_wr(w_Flags_wr),
        .SP_inc(w_SP_inc), .SP_dec(w_SP_dec), .addr_sel(w_addr_sel),
        
        // Fio novo ligado na FSM
        .out_wr(w_out_wr) 
    );

    datapath inst_datapath (
        .clk(clk),
        .rst(rst),
        
        // Pinos novos ligados no exterior do chip
        .in_port(in_port),
        .out_port(out_port),
        .out_wr(w_out_wr),
        
        .ROM_en(w_ROM_en), .PC_clr(w_PC_clr), .PC_inc(w_PC_inc), .PC_ld(w_PC_ld),
        .IR_load(w_IR_load), .Immed(w_Immed), .RF_sel(w_RF_sel), .Rd_sel(w_Rd_sel),
        .Rd_wr(w_Rd_wr), .RAM_wr(w_RAM_wr), .Rm_sel(w_Rm_sel), .Rn_sel(w_Rn_sel),
        .ula_op(w_ula_op), .flag_Z(w_flag_Z), .flag_C(w_flag_C), .Flags_wr(w_Flags_wr),
        .SP_inc(w_SP_inc), .SP_dec(w_SP_dec), .addr_sel(w_addr_sel),
        
        .IR_data(w_IR_data)       
    );

endmodule
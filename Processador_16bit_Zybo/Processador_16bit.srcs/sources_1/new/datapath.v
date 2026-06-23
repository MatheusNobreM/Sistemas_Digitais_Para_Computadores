`timescale 1ns / 1ps

module datapath (
    input  wire clk,
    input  wire rst,

    // --- PORTAS DE COMUNICAÇÃO EXTERNA (E/S) ---
    input  wire [15:0] in_port,   
    output reg  [15:0] out_port,  
    input  wire        out_wr,    

    // Sinais de Controle
    input  wire ROM_en,
    input  wire PC_clr,
    input  wire PC_inc,
    input  wire PC_ld,     
    input  wire IR_load,
    input  wire [15:0] Immed,     
    input  wire [1:0]  RF_sel,    
    input  wire [2:0]  Rd_sel,    
    input  wire        Rd_wr,     
    input  wire        RAM_wr,    
    input  wire [2:0]  Rm_sel,    
    input  wire [2:0]  Rn_sel,    
    input  wire [3:0]  ula_op,    
    input  wire        Flags_wr,  
    input  wire        SP_inc,    
    input  wire        SP_dec,    
    input  wire        addr_sel,  

    output wire [15:0] IR_data,   
    output wire        flag_Z,    
    output wire        flag_C     
);

    wire [15:0] w_pc_out;
    wire [15:0] w_rom_out;
    wire [15:0] w_mux_rf_out;
    wire [15:0] w_rm_out;
    wire [15:0] w_rn_out;
    wire [15:0] w_ula_out;
    wire [15:0] w_ram_out;
    
    reg  [15:0] SP;
    wire [15:0] w_ram_addr;
    wire w_Z_ula;
    wire w_C_ula;
    reg r_Z;
    reg r_C;

    wire [15:0] w_jump_target;
    assign w_jump_target = w_pc_out + Immed;

    // --- MUX DE DADOS DA RAM  ---
    // Se addr_sel=1 (Pilhas), gravamos Rm. Se addr_sel=0 (Store), gravamos Rn.
    wire [15:0] w_ram_din = addr_sel ? w_rm_out : w_rn_out;

    // ==========================================
    // REGISTRADOR DE SAÍDA (OUT)
    // ==========================================
    always @(posedge clk or posedge rst) begin
        if (rst) out_port <= 16'd0;
        else if (out_wr) out_port <= w_mux_rf_out; 
    end

    // STACK POINTER
    always @(posedge clk or posedge rst) begin
        if (rst) SP <= 16'd255; 
        else if (SP_dec) SP <= SP - 16'd1; 
        else if (SP_inc) SP <= SP + 16'd1; 
    end
    assign w_ram_addr = addr_sel ? (SP_inc ? SP + 16'd1 : SP) : w_rm_out;

    // STATUS REGISTER 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r_Z <= 1'b0;
            r_C <= 1'b0;
        end else if (Flags_wr) begin
            r_Z <= w_Z_ula;
            r_C <= w_C_ula;
        end
    end
    assign flag_Z = r_Z;
    assign flag_C = r_C;

    // ==========================================
    // INSTANCIAÇÕES
    // ==========================================
    pc inst_pc (
        .clk(clk), .rst(rst), .PC_clr(PC_clr), .PC_inc(PC_inc),
        .ld(PC_ld), .D(w_jump_target), .Q(w_pc_out)
    );

    rom inst_rom (
        .clk(clk), .en(ROM_en), .addr(w_pc_out), .dout(w_rom_out)
    );

    ir inst_ir (
        .clk(clk), .rst(rst), .ld(IR_load), .D(w_rom_out), .Q(IR_data) 
    );

    mux4 inst_mux_rf (
        .I0(w_ula_out), .I1(w_ram_out), .I2(Immed), .I3(in_port),
        .sel(RF_sel), .out(w_mux_rf_out)
    );

    register_file inst_rf (
        .clk(clk), .rst(rst), .Rd_sel(Rd_sel), .Rd_wr(Rd_wr),
        .Rd_data(w_mux_rf_out), .Rm_sel(Rm_sel), .Rn_sel(Rn_sel),
        .Rm(w_rm_out), .Rn(w_rn_out)
    );

    ula inst_ula (
        .A(w_rm_out), .B(w_rn_out), .shamt(IR_data[4:0]), 
        .op(ula_op), .Q(w_ula_out), .Z(w_Z_ula), .C(w_C_ula)   
    );
    
    ram inst_ram (
        .clk(clk), .wr_en(RAM_wr), .addr(w_ram_addr), 
        .din(w_ram_din),     // <--- AGORA USA O MUX CORRIGIDO
        .dout(w_ram_out) 
    );

endmodule
`timescale 1ns / 1ps

module tb_datapath();

    // --------------------------------------------------
    // Entradas - sinais de controle (vindos da FSM)
    // --------------------------------------------------
    reg         clk;
    reg         rst;
    reg         ROM_en;
    reg         PC_clr;
    reg         PC_inc;
    reg         PC_ld;
    reg         IR_load;
    reg  [15:0] Immed;
    reg  [1:0]  RF_sel;
    reg  [2:0]  Rd_sel;
    reg         Rd_wr;
    reg         RAM_wr;
    reg  [2:0]  Rm_sel;
    reg  [2:0]  Rn_sel;
    reg  [3:0]  ula_op;
    reg         Flags_wr; 
    reg         SP_inc;   
    reg         SP_dec;   
    reg         addr_sel; 
    reg         out_wr;   
    reg  [15:0] in_port;  

    // --------------------------------------------------
    // Saídas
    // --------------------------------------------------
    wire [15:0] IR_data;
    wire        flag_Z;   
    wire        flag_C;   
    wire [15:0] out_port; 

    // Instanciação corrigida - todas as portas conectadas
    datapath dut (
        .clk(clk),
        .rst(rst),
        .in_port(in_port),
        .out_port(out_port),
        .out_wr(out_wr),
        .ROM_en(ROM_en),
        .PC_clr(PC_clr),
        .PC_inc(PC_inc),
        .PC_ld(PC_ld),
        .IR_load(IR_load),
        .Immed(Immed),
        .RF_sel(RF_sel),
        .Rd_sel(Rd_sel),
        .Rd_wr(Rd_wr),
        .RAM_wr(RAM_wr),
        .Rm_sel(Rm_sel),
        .Rn_sel(Rn_sel),
        .ula_op(ula_op),
        .Flags_wr(Flags_wr),
        .SP_inc(SP_inc),
        .SP_dec(SP_dec),
        .addr_sel(addr_sel),
        .IR_data(IR_data),
        .flag_Z(flag_Z),
        .flag_C(flag_C)
    );

    always #5 clk = ~clk;

    // Tarefa auxiliar: inicializa todos os sinais de controle em 0
    task reset_ctrl;
        begin
            ROM_en=0; PC_clr=0; PC_inc=0; PC_ld=0;
            IR_load=0; Immed=0; RF_sel=2'b00;
            Rd_sel=0; Rd_wr=0; RAM_wr=0;
            Rm_sel=0; Rn_sel=0; ula_op=4'b0000;
            Flags_wr=0; SP_inc=0; SP_dec=0;
            addr_sel=0; out_wr=0;
        end
    endtask

    initial begin
        // Inicialização
        clk=0; rst=1; in_port=16'd0;
        reset_ctrl();

        #15; rst=0; #5;

        // ================================================
        // Teste 1: MOV R1, #42
        // Fetch endereço 0 da ROM (instrução já gravada lá)
        // ================================================
        ROM_en=1; IR_load=1; PC_inc=1; #10;
        IR_load=0; PC_inc=0;
        Immed={8'd0, IR_data[7:0]};
        RF_sel=2'b10; Rd_sel=3'd1; Rd_wr=1; #10;
        Rd_wr=0;
        $display("MOV R1,#42: IR_data=%b", IR_data);

        // ================================================
        // Teste 2: MOV R2, #10 (endereço 2 da ROM)
        // ================================================
        ROM_en=1; IR_load=1; PC_inc=1; #10;
        IR_load=0; PC_inc=0;
        Immed={8'd0, IR_data[7:0]};
        RF_sel=2'b10; Rd_sel=3'd2; Rd_wr=1; #10;
        Rd_wr=0;

        // ================================================
        // Teste 3: ADD R3, R1, R2
        // ================================================
        ROM_en=1; IR_load=1; PC_inc=1; #10;
        IR_load=0; PC_inc=0;
        Rm_sel=3'd1; Rn_sel=3'd2;
        ula_op=4'b0100;
        RF_sel=2'b00; Rd_sel=3'd3; Rd_wr=1; #10;
        Rd_wr=0;
        $display("ADD R3=R1+R2: esperado 52");

        // ================================================
        // Teste 4: CMP R1, R2 → R1(42) > R2(10) → Z=0, C=0
        // ================================================
        reset_ctrl();
        Rm_sel=3'd1; Rn_sel=3'd2;
        ula_op=4'b1011; Flags_wr=1; #10;
        Flags_wr=0;
        $display("CMP R1>R2: flag_Z=%b (exp 0), flag_C=%b (exp 0)", flag_Z, flag_C);

        // ================================================
        // Teste 5: CMP R2, R1 → R2(10) < R1(42) → Z=0, C=1
        // ================================================
        Rm_sel=3'd2; Rn_sel=3'd1;
        ula_op=4'b1011; Flags_wr=1; #10;
        Flags_wr=0;
        $display("CMP R2<R1: flag_Z=%b (exp 0), flag_C=%b (exp 1)", flag_Z, flag_C);

        // ================================================
        // Teste 6: IN - lê in_port=99 para R5
        // ================================================
        reset_ctrl();
        in_port=16'd99;
        RF_sel=2'b11; Rd_sel=3'd5; Rd_wr=1; #10;
        Rd_wr=0;
        $display("IN R5=in_port(99): verificar R5 no waveform");

        // ================================================
        // Teste 7: OUT - escreve R5 em out_port
        //   PASS A: Rm_sel=R5, ula_op=0000, RF_sel=00, out_wr=1
        // ================================================
        reset_ctrl();
        Rm_sel=3'd5; ula_op=4'b0000;
        RF_sel=2'b00; out_wr=1; #10;
        out_wr=0;
        $display("OUT: out_port=%d (esperado 99)", out_port);

        // ================================================
        // Teste 8: PSH R5 (empilha 99 na RAM)
        //   addr_sel=1, RAM_wr=1, SP_dec=1, Rm_sel=R5
        // ================================================
        reset_ctrl();
        Rm_sel=3'd5; addr_sel=1; RAM_wr=1; SP_dec=1; #10;
        RAM_wr=0; SP_dec=0;
        $display("PSH R5(99): verificar RAM[255] no waveform");

        // ================================================
        // Teste 9: POP R6 (recupera 99 da RAM para R6)
        //   SP_inc=1, addr_sel=1, RF_sel=01, Rd_wr=1, Rd_sel=R6
        // ================================================
        reset_ctrl();
        SP_inc=1; addr_sel=1; RF_sel=2'b01; Rd_sel=3'd6; Rd_wr=1; #10;
        SP_inc=0; Rd_wr=0;
        $display("POP R6: verificar R6=99 no waveform");

        $display("Testes do Datapath finalizados!");
        $finish;
    end

endmodule
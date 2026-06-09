`timescale 1ns / 1ps

module tb_fsm();

    // --------------------------------------------------
    // Entradas
    // --------------------------------------------------
    reg         clk;
    reg         rst;
    reg  [15:0] IR_data;
    reg         flag_Z;   // realimenta flags para testar JEQ/JGT
    reg         flag_C;  

    // --------------------------------------------------
    // Saídas - sinais de controle gerados pela FSM
    // --------------------------------------------------
    wire        ROM_en;
    wire        PC_clr;
    wire        PC_inc;
    wire        PC_ld;
    wire        IR_load;
    wire [15:0] Immed;
    wire [1:0]  RF_sel;
    wire [2:0]  Rd_sel;
    wire        Rd_wr;
    wire        RAM_wr;
    wire [2:0]  Rm_sel;
    wire [2:0]  Rn_sel;
    wire [3:0]  ula_op;
    wire        Flags_wr; 
    wire        SP_inc;   
    wire        SP_dec;   
    wire        addr_sel; 
    wire        out_wr;   

    // Instanciação corrigida - todas as portas conectadas
    fsm dut (
        .clk(clk),
        .rst(rst),
        .IR_data(IR_data),
        .flag_Z(flag_Z),
        .flag_C(flag_C),
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
        .out_wr(out_wr)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1;
        IR_data = 16'd0;
        flag_Z  = 0; flag_C = 0;

        #15; rst = 0; #5;

        // ------------------------------------------------
        // Teste 1: MOV R1, #42 (opcode 00011)
        // Esperado: RF_sel=10, Rd_wr=1, Rd_sel=001
        // ------------------------------------------------
        IR_data = 16'b00011_001_00101010;
        #20;
        $display("MOV: Rd_wr=%b (exp 1), RF_sel=%b (exp 10)", Rd_wr, RF_sel);

        // ------------------------------------------------
        // Teste 2: ADD R3, R1, R2 (opcode 01000)
        // Esperado: ula_op=0100, RF_sel=00, Rd_wr=1
        // ------------------------------------------------
        IR_data = 16'b01000_011_001_010_00;
        #20;
        $display("ADD: ula_op=%b (exp 0100), Rd_wr=%b (exp 1)", ula_op, Rd_wr);

        // ------------------------------------------------
        // Teste 3: CMP Rm, Rn (opcode 00000, bits[1:0]=11)
        // Esperado: ula_op=1011, Flags_wr=1
        // ------------------------------------------------
        IR_data = 16'b00000_000_001_111_11;
        #20;
        $display("CMP: Flags_wr=%b (exp 1), ula_op=%b (exp 1011)", Flags_wr, ula_op);

        // ------------------------------------------------
        // Teste 4: JMP incondicional (opcode 00001, bits[1:0]=00)
        // Esperado: PC_ld=1 independente das flags
        // ------------------------------------------------
        IR_data = 16'b00001_000010010_00;
        flag_Z = 0; flag_C = 0;
        #20;
        $display("JMP: PC_ld=%b (exp 1)", PC_ld);

        // ------------------------------------------------
        // Teste 5: JEQ com Z=1 (bits[1:0]=01)
        // Esperado: PC_ld=1
        // ------------------------------------------------
        IR_data = 16'b00001_000010010_01;
        flag_Z = 1; flag_C = 0;
        #20;
        $display("JEQ Z=1: PC_ld=%b (exp 1)", PC_ld);

        // ------------------------------------------------
        // Teste 6: JEQ com Z=0 (bits[1:0]=01)
        // Esperado: PC_ld=0 (não desvia)
        // ------------------------------------------------
        flag_Z = 0;
        #20;
        $display("JEQ Z=0: PC_ld=%b (exp 0)", PC_ld);

        // ------------------------------------------------
        // Teste 7: PSH (opcode 00000, bits[1:0]=01)
        // Esperado: addr_sel=1, RAM_wr=1, SP_dec=1
        // ------------------------------------------------
        IR_data = 16'b00000_000_010_000_01;
        flag_Z = 0; flag_C = 0;
        #20;
        $display("PSH: addr_sel=%b (exp 1), RAM_wr=%b (exp 1), SP_dec=%b (exp 1)",
                  addr_sel, RAM_wr, SP_dec);

        // ------------------------------------------------
        // Teste 8: POP (opcode 00000, bits[1:0]=10)
        // Esperado: SP_inc=1, addr_sel=1, RF_sel=01, Rd_wr=1
        // ------------------------------------------------
        IR_data = 16'b00000_011_000_000_10;
        #20;
        $display("POP: SP_inc=%b (exp 1), Rd_wr=%b (exp 1), RF_sel=%b (exp 01)",
                  SP_inc, Rd_wr, RF_sel);

        // ------------------------------------------------
        // Teste 9: IN Rd (opcode 11110, bits[1:0]=01)
        // Esperado: RF_sel=11, Rd_wr=1
        // ------------------------------------------------
        IR_data = 16'b11110_001_000000_01;
        #20;
        $display("IN: RF_sel=%b (exp 11), Rd_wr=%b (exp 1)", RF_sel, Rd_wr);

        // ------------------------------------------------
        // Teste 10: OUT Rm (opcode 11110, bits[1:0]=10)
        // Esperado: out_wr=1, ula_op=0000
        // ------------------------------------------------
        IR_data = 16'b11110_000_100_000_10;
        #20;
        $display("OUT Rm: out_wr=%b (exp 1), ula_op=%b (exp 0000)", out_wr, ula_op);

        // ------------------------------------------------
        // Teste 11: HALT (opcode 11111)
        // Esperado: FSM trava em HALT_ST para sempre
        // ------------------------------------------------
        IR_data = 16'b11111_000_00000000;
        #40;
        $display("HALT: PC_inc=%b (exp 0), ROM_en=%b (exp 0)", PC_inc, ROM_en);

        $display("Testes da FSM finalizados!");
        $finish;
    end

endmodule
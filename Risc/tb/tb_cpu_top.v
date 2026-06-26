`timescale 1ns / 1ps

module tb_cpu_top();

    reg  clk;
    reg  rst;
    reg  [7:0] in_port;     // chaves
    wire [7:0] out_port;    // LEDs
    wire       halt_out;

    cpu_top uut (
        .clk(clk),
        .rst(rst),
        .in_port(in_port),
        .out_port(out_port),
        .halt_out(halt_out)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        in_port = 8'h00;

        #20;
        rst = 0; #100;   // sai do reset: amostra chaves=0 -> LEDs=0 e da HLT
        $display("reset com chaves=%b -> LEDs=%b (esperado 0000)", in_port[3:0], out_port[3:0]);

        // 1) ajusta as chaves e PULSA o reset -> LEDs travam nesse valor
        in_port = 8'h05;
        rst = 1; #20; rst = 0; #100;
        $display("chaves=%b + reset -> LEDs=%b (esperado 0101)", in_port[3:0], out_port[3:0]);

        // 2) muda as chaves SEM resetar -> LEDs NAO mudam (CPU em HLT)
        in_port = 8'h0A; #100;
        $display("chaves=%b sem reset -> LEDs=%b (esperado continua 0101)", in_port[3:0], out_port[3:0]);

        // 3) PULSA o reset de novo -> LEDs carregam o novo valor das chaves
        rst = 1; #20; rst = 0; #100;
        $display("chaves=%b + reset -> LEDs=%b (esperado 1010)", in_port[3:0], out_port[3:0]);

        $display("Simulacao finalizada.");
        $finish;
    end

endmodule

# AGENTS.md

## Contexto do projeto

Este repositorio contem um processador de 16 bits em Verilog criado originalmente no Vivado.
O arquivo `Processador_16bit.xpr` e o projeto do Vivado, mas algumas ferramentas, como DigitalJS/TerosHDL, nao usam o `.xpr` para descobrir automaticamente as fontes de sintese.

As fontes reais do processador ficam em:

```text
Processador_16bit.srcs/sources_1/new/
```

O modulo principal do processador e:

```text
processador_top
```

Portas do `processador_top`:

```verilog
input  wire        clk
input  wire        rst
input  wire [15:0] in_port
output wire [15:0] out_port
```

## O que foi feito

Foi criada uma pasta no estilo do exemplo `TESTE_DA_ZYBO`, sem depender do `.xpr`:

```text
TESTE_DA_ZYBO/TESTE_DA_ZYBO/
```

Dentro dela foram criados:

```text
top.v
build.tcl
program.tcl
makefile
zybo.xdc
README.md
top.bit
```

O objetivo dessa pasta e compilar o processador para a placa Zybo usando scripts Tcl do Vivado.

## Estrutura criada

### `top.v`

Wrapper fisico para a Zybo. Ele instancia `processador_top` e adapta os pinos da placa:

```text
clk      -> clk do processador
btn[0]   -> rst do processador
sw[3:0]  -> in_port[3:0]
led[3:0] -> out_port[3:0]
```

Os 12 bits altos de `in_port` ficam em zero:

```verilog
assign in_port = {12'd0, sw};
```

### `build.tcl`

Script que cria um projeto Vivado em memoria e adiciona explicitamente todos os arquivos Verilog com `read_verilog`.

Ele le:

```text
top.v
processador_top.v
datapath.v
fsm.v
pc.v
rom.v
ir.v
mux4.v
register_file.v
ula.v
ram.v
```

Depois executa:

```tcl
synth_design -top top
opt_design
place_design
route_design
write_bitstream -force top.bit
```

Importante: os caminhos usam listas Tcl em `read_verilog` porque o caminho do projeto tem espacos, por exemplo `Sistemas digitais para computadores`.

### `zybo.xdc`

Arquivo de constraints minimo para Zybo Rev B. Define:

```text
clk
sw[3:0]
btn[3:0]
led[3:0]
```

### `program.tcl`

Abre o hardware manager do Vivado, conecta na Zybo e grava:

```text
top.bit
```

### `makefile`

Atalhos:

```sh
make build
make program
make clean
```

No Windows, se `make` nao estiver disponivel, use diretamente o `vivado.bat`.

## Comandos verificados

O Vivado nao estava no `PATH`, mas foi encontrado em:

```text
C:/Xilinx/Vivado/2024.2/bin/vivado.bat
```

Build validada com:

```powershell
& "C:\Xilinx\Vivado\2024.2\bin\vivado.bat" -mode batch -source build.tcl
```

O bitstream foi gerado com sucesso em:

```text
TESTE_DA_ZYBO/TESTE_DA_ZYBO/top.bit
```

Para programar a placa:

```powershell
& "C:\Xilinx\Vivado\2024.2\bin\vivado.bat" -mode batch -source program.tcl
```

## Observacoes importantes

- Nao incluir arquivos `tb_*.v` em sintese. Eles sao testbenches de simulacao.
- O arquivo `mux2.v` existe, mas nao e usado pelo `processador_top` atual.
- O erro `No source file added for synthesis` acontece quando a ferramenta nao recebeu os arquivos `.v` como fontes de sintese.
- A solucao foi adicionar os Verilog explicitamente no `build.tcl`, em vez de depender do `.xpr`.
- A build gerou `top.bit`, mas o Vivado avisou que o design nao fecha timing para 125 MHz da Zybo.

Timing observado:

```text
WNS = -2.376
```

Isso indica que, para uso estavel em hardware real, o proximo ajuste recomendado e reduzir a frequencia efetiva do processador, por exemplo com um divisor de clock ou clock enable.

## Proximo passo sugerido

Criar um clock enable mais lento no `top.v` e alimentar o processador com esse pulso, ou inserir um divisor de clock simples. Isso deve melhorar a estabilidade na Zybo e evitar depender de o processador rodar direto no clock de 125 MHz da placa.

# Contexto do Projeto - Processador 16-bit Zybo

Este arquivo resume o projeto inteiro para facilitar manutencao, uso com
ferramentas de HDL e continuidade do desenvolvimento.

## Visao geral

Este repositorio contem um processador didatico de 16 bits escrito em Verilog.
O projeto foi criado originalmente no Vivado e possui o arquivo:

```text
Processador_16bit.xpr
```

Esse arquivo abre o projeto completo no Vivado, mas ferramentas como
DigitalJS, TerosHDL ou scripts externos nem sempre usam o `.xpr` para descobrir
as fontes automaticamente. Por isso, a parte importante do codigo esta nos
arquivos Verilog dentro de:

```text
Processador_16bit.srcs/sources_1/new/
```

O modulo principal logico do processador e:

```verilog
processador_top
```

Ele possui a seguinte interface:

```verilog
input  wire        clk
input  wire        rst
input  wire [15:0] in_port
output wire [15:0] out_port
```

## Objetivo do projeto

O objetivo e sintetizar e executar o processador de 16 bits em uma placa Zybo,
usando o clock da placa, botoes, chaves e LEDs como interface fisica simples.

A pasta criada para isso e:

```text
TESTE_DA_ZYBO/TESTE_DA_ZYBO/
```

Ela permite compilar e programar a placa por scripts Tcl do Vivado, sem
depender diretamente do arquivo `.xpr`.

## Estrutura principal do repositorio

```text
Processador_16bit.xpr
```

Projeto original do Vivado.

```text
Processador_16bit.srcs/sources_1/new/
```

Fontes Verilog reais do processador.

```text
Processador_16bit.srcs/sim_1/new/
```

Testbenches de simulacao. Arquivos `tb_*.v` nao devem entrar na sintese.

```text
TESTE_DA_ZYBO/TESTE_DA_ZYBO/
```

Projeto minimo por script para sintetizar, implementar, gerar bitstream e
programar a Zybo.

## Arquivos Verilog do processador

### `processador_top.v`

Modulo principal logico. Ele conecta duas partes:

- `fsm`: unidade de controle.
- `datapath`: caminho de dados.

Tambem passa sinais de controle entre a FSM e o datapath, como:

- leitura da ROM;
- incremento ou carga do PC;
- carga do IR;
- escrita no banco de registradores;
- escrita na RAM;
- operacao da ULA;
- escrita das flags;
- controle da pilha;
- escrita na saida externa.

### `fsm.v`

Unidade de controle do processador.

Ela implementa uma maquina de estados simples com:

```text
FETCH
EXECUTE
HALT_ST
```

No estado `FETCH`, a FSM habilita a ROM, carrega a instrucao no IR e incrementa
o PC.

No estado `EXECUTE`, ela decodifica o opcode da instrucao:

```verilog
IR_data[15:11]
```

Depois gera os sinais de controle necessarios para executar a instrucao.

O estado `HALT_ST` trava a maquina em parada.

### `datapath.v`

Caminho de dados do processador. Ele contem e conecta:

- PC;
- ROM;
- IR;
- mux de selecao para escrita no banco de registradores;
- banco de registradores;
- ULA;
- RAM;
- stack pointer;
- registrador de flags;
- registrador de saida externa.

A entrada externa `in_port` pode ser escrita em um registrador por instrucao
`IN`.

A saida externa `out_port` e atualizada quando a FSM ativa `out_wr`, normalmente
por uma instrucao `OUT`.

### `pc.v`

Program Counter de 16 bits.

Funcoes:

- zera em `rst` ou `PC_clr`;
- carrega um novo endereco quando `ld` esta ativo;
- incrementa de 2 em 2 quando `PC_inc` esta ativo.

O incremento de 2 indica que as instrucoes sao tratadas como palavras de 16
bits em enderecos pares.

### `rom.v`

Memoria de programa com 256 posicoes de 16 bits.

Ela e inicializada no proprio Verilog com um programa de exemplo. O programa
atual:

1. le um valor externo por `IN R1`;
2. inicializa valores para calcular Fibonacci;
3. usa pilha com `PSH` e `POP`;
4. executa um loop;
5. escreve o resultado em `out_port` com `OUT R4`;
6. finaliza com `HALT`.

A leitura da ROM e combinacional:

```verilog
dout = memoria[addr[7:0]]
```

### `ir.v`

Instruction Register.

Armazena a instrucao lida da ROM quando `ld` esta ativo.

### `register_file.v`

Banco de 8 registradores de 16 bits:

```text
R0 a R7
```

Caracteristicas:

- leitura combinacional por `Rm_sel` e `Rn_sel`;
- escrita sincronizada por clock em `Rd_sel`;
- reset zera todos os registradores.

### `ula.v`

Unidade Logica e Aritmetica.

Operacoes implementadas:

```text
PASS A
ADD
SUB
MUL
AND
OR
NOT
XOR
CMP
SHL
SHR
ROL
ROR
```

A operacao `CMP` atualiza:

- `Z`: 1 quando `A == B`;
- `C`: 1 quando `A < B`.

As flags reais ficam armazenadas no datapath e so mudam quando `Flags_wr` esta
ativo.

### `ram.v`

RAM de dados com 256 posicoes de 16 bits.

Caracteristicas:

- escrita sincronizada no clock;
- leitura combinacional;
- endereco efetivo usa `addr[7:0]`.

Tambem e usada para a pilha.

### `mux4.v`

Multiplexador 4 para 1 de 16 bits.

Seleciona a fonte de dados que sera escrita no banco de registradores ou usada
para saida:

```text
00 -> resultado da ULA
01 -> saida da RAM
10 -> imediato
11 -> in_port
```

### `mux2.v`

Multiplexador 2 para 1 de 16 bits.

Existe no projeto, mas nao e usado pela versao atual do `processador_top`.

## Formato geral das instrucoes

As instrucoes possuem 16 bits.

O opcode principal fica em:

```verilog
IR_data[15:11]
```

Campos comuns usados pela FSM:

```text
IR_data[10:8] -> Rd
IR_data[7:5]  -> Rm
IR_data[4:2]  -> Rn
IR_data[1:0]  -> subtipo em algumas instrucoes
```

Algumas instrucoes usam imediatos:

- `MOV Rd, #Im`: imediato de 8 bits em `IR_data[7:0]`;
- jumps: imediato relativo com sinal em `IR_data[10:2]`;
- shifts: quantidade de shift em `IR_data[4:0]`;
- `OUT #Im`: imediato montado com partes da instrucao.

## Instrucoes reconhecidas pela FSM

Resumo por opcode:

```text
00000 -> CMP, PSH, POP, NOP, conforme IR_data[1:0]
00001 -> jumps condicionais e incondicional
00010 -> MOV Rd, Rm
00011 -> MOV Rd, #Im
00100 -> STR
00110 -> LDR
00111 -> LDR
01000 -> ADD
01001 -> ADD
01010 -> SUB
01011 -> SUB
01100 -> MUL
01101 -> MUL
01110 -> AND
01111 -> AND
10000 -> ORR
10001 -> ORR
10010 -> NOT
10011 -> NOT
10100 -> XOR
10101 -> XOR
10110 -> SHR
10111 -> SHR
11000 -> SHL
11001 -> SHL
11010 -> ROR
11011 -> ROR
11100 -> ROL
11101 -> ROL
11110 -> IN ou OUT por registrador
11111 -> HALT ou OUT imediato, dependendo da decodificacao atual
```

## Programa atual gravado na ROM

O programa de exemplo em `rom.v` usa a entrada externa como numero de iteracoes.
Na Zybo, essa entrada vem das chaves `sw[3:0]`.

Fluxo simplificado:

1. `IN R1`: le as chaves.
2. `MOV R2, #0`: valor inicial N-2.
3. `MOV R3, #1`: valor inicial N-1.
4. `MOV R7, #0`: zero usado em comparacao.
5. Empilha os valores iniciais.
6. Compara o contador `R1` com zero.
7. Se chegou a zero, sai do loop.
8. Calcula o proximo termo com `ADD`.
9. Atualiza a pilha.
10. Decrementa o contador.
11. Volta ao loop.
12. Ao final, faz `OUT R4`.
13. Executa `HALT`.

Na placa, somente os 4 bits baixos da saida aparecem nos LEDs:

```text
led[3:0] <- out_port[3:0]
```

## Wrapper fisico para a Zybo

O arquivo:

```text
TESTE_DA_ZYBO/TESTE_DA_ZYBO/top.v
```

adapta o `processador_top` para os pinos reais usados na placa.

Interface fisica:

```verilog
input  wire       clk
input  wire [3:0] btn
input  wire [3:0] sw
output wire [3:0] led
```

Ligacoes:

```text
clk      -> clk do processador
btn[0]   -> rst do processador
sw[3:0]  -> in_port[3:0]
led[3:0] -> out_port[3:0]
```

Os bits altos da entrada ficam fixos em zero:

```verilog
assign in_port = {12'd0, sw};
```

## Constraints da Zybo

O arquivo:

```text
TESTE_DA_ZYBO/TESTE_DA_ZYBO/zybo.xdc
```

define os pinos fisicos para:

- clock;
- 4 chaves;
- 4 botoes;
- 4 LEDs.

O clock esta declarado com periodo de 8 ns:

```text
125 MHz
```

## Build por Tcl

O arquivo:

```text
TESTE_DA_ZYBO/TESTE_DA_ZYBO/build.tcl
```

cria um projeto Vivado em memoria:

```tcl
create_project -in_memory -part xc7z010clg400-1
```

Depois adiciona explicitamente os Verilog com `read_verilog`.

Isso e importante porque o caminho do projeto tem espacos:

```text
Sistemas digitais para computadores
```

Por isso os caminhos usam listas Tcl:

```tcl
read_verilog [list [file join ...]]
```

O fluxo executado e:

```tcl
synth_design -top top
opt_design
place_design
route_design
write_bitstream -force top.bit
```

O bitstream gerado fica em:

```text
TESTE_DA_ZYBO/TESTE_DA_ZYBO/top.bit
```

## Programacao da placa

O arquivo:

```text
TESTE_DA_ZYBO/TESTE_DA_ZYBO/program.tcl
```

abre o hardware manager, conecta na Zybo, seleciona o dispositivo e grava:

```text
top.bit
```

## Makefile

O arquivo:

```text
TESTE_DA_ZYBO/TESTE_DA_ZYBO/makefile
```

fornece atalhos:

```sh
make build
make program
make clean
```

No Windows, se `make` nao estiver disponivel, use o Vivado diretamente.

## Comandos recomendados no Windows

Entrar na pasta:

```powershell
cd "C:\Users\Matheus\Documents\Faculdade\Sistemas digitais para computadores\Processador_16bit_Zybo\TESTE_DA_ZYBO\TESTE_DA_ZYBO"
```

Gerar o bitstream:

```powershell
& "C:\Xilinx\Vivado\2024.2\bin\vivado.bat" -mode batch -source build.tcl
```

Programar a placa:

```powershell
& "C:\Xilinx\Vivado\2024.2\bin\vivado.bat" -mode batch -source program.tcl
```

## Pontos importantes

- Nao adicionar `tb_*.v` na sintese.
- O arquivo `mux2.v` existe, mas nao e usado atualmente.
- O projeto da Zybo nao depende do `.xpr`.
- O `build.tcl` adiciona as fontes manualmente.
- O erro `No source file added for synthesis` normalmente significa que os `.v`
  nao foram passados como fontes de sintese.
- O `top.bit` ja foi gerado com sucesso anteriormente.

## Limitacao atual de timing

A build anterior gerou bitstream, mas o design nao fechou timing para o clock
de 125 MHz da Zybo.

Timing observado:

```text
WNS = -2.376
```

Isso indica que o processador pode nao operar de forma estavel em hardware real
rodando diretamente a 125 MHz.

## Proximo ajuste recomendado

Adicionar um clock mais lento para o processador.

Opcoes comuns:

1. divisor de clock simples em `top.v`;
2. clock enable gerado em `top.v`;
3. PLL/MMCM, se quiser gerar outro clock de forma mais formal no Vivado.

Para este projeto didatico, a opcao mais simples costuma ser um divisor ou um
clock enable. Assim a placa continua recebendo 125 MHz, mas o processador so
avanca em uma frequencia menor.

## Como explicar o fluxo completo

O fluxo do projeto e:

1. O programa fica escrito na ROM em `rom.v`.
2. O PC aponta para a proxima instrucao.
3. A FSM faz `FETCH`: le a instrucao da ROM para o IR e incrementa o PC.
4. A FSM faz `EXECUTE`: decodifica a instrucao e gera sinais de controle.
5. O datapath executa a operacao usando registradores, ULA, RAM, pilha e portas
   de entrada/saida.
6. Quando uma instrucao `OUT` acontece, `out_port` e atualizado.
7. Na Zybo, `out_port[3:0]` aparece nos LEDs.
8. Quando uma instrucao `IN` acontece, o processador le `in_port`.
9. Na Zybo, `in_port[3:0]` vem das chaves.
10. Quando `HALT` e executado, a FSM fica parada em `HALT_ST`.

## Resumo curto para ferramentas de IA

Este repositorio contem um processador didatico de 16 bits em Verilog para a
Zybo. As fontes sintetizaveis ficam em
`Processador_16bit.srcs/sources_1/new/`, e o top logico e `processador_top`.
A pasta `TESTE_DA_ZYBO/TESTE_DA_ZYBO/` contem um wrapper fisico `top.v`,
constraints `zybo.xdc`, scripts `build.tcl` e `program.tcl`, e um `makefile`.
O wrapper liga `btn[0]` ao reset, `sw[3:0]` a `in_port[3:0]` e `out_port[3:0]`
aos LEDs. O build usa Vivado 2024.2 em modo batch e gera `top.bit`. A ROM atual
contem um programa de exemplo com entrada externa, pilha, loop de Fibonacci,
saida em `OUT R4` e `HALT`. O timing anterior nao fechou em 125 MHz
(`WNS = -2.376`), entao o proximo passo recomendado e reduzir a frequencia
efetiva do processador com divisor de clock ou clock enable.

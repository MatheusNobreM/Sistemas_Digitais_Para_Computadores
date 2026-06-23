# Processador Acumulador 16-bit (RISC didático)

Processador didático de 16 bits em Verilog, baseado em **acumulador**, conforme
o diagrama da avaliação AP2. Inclui simulação no Vivado (XSim) e execução na
placa **Zybo**, onde os **LEDs são controlados pelo processador executando um
programa em assembly** (I/O mapeado em memória).

## Visão geral

A CPU tem um único registrador de dados (o **acumulador, AC**) e executa um
programa guardado na memória. É uma arquitetura de von Neumann com máquina de
**2 fases**:

- **FETCH** (`phase = 0`): lê a instrução apontada pelo PC, carrega no IR e
  incrementa o PC.
- **EXECUTE** (`phase = 1`): decodifica o opcode e executa a operação.

Interface do módulo lógico `cpu_top`:

```verilog
input  wire        clk
input  wire        rst
input  wire [15:0] in_port    // CHAVES  (entrada)
output wire [15:0] out_port   // LEDs    (saida)
output wire        halt_out
```

## Estrutura do repositório

```text
componentes/          -> fontes Verilog sintetizáveis (CPU + wrapper Zybo)
tb/                   -> testbenches de simulação (NÃO entram na síntese)
Zybo_Constraints.xdc  -> pinos físicos da Zybo
build.tcl / program.tcl / makefile -> build e gravação por script
Rsic_Pro/             -> projeto Vivado (.xpr)
```

## Componentes (`componentes/`)

| Arquivo | Bloco | Função |
|---|---|---|
| `top.v` | wrapper Zybo | liga a CPU aos pinos: chaves→entrada, saída→LEDs, BTN0→reset |
| `cpu_top.v` | topo da CPU | conecta os módulos + I/O mapeado em memória |
| `counter_clk.v` | phase generator | gera `phase` (FETCH/EXECUTE), para no `halt` |
| `controller_inst.v` | controller | decodifica opcode → sinais de controle |
| `counter_pc.v` | program counter | PC: reset, carga (`ld_pc`) e incremento (`inc_pc`) |
| `address_mux.v` | multiplexor | endereço: PC (fetch) ou IR (operando) |
| `register_ir.v` | instruction register | guarda a instrução; separa `opcode` e `ir_addr` |
| `alu_inst.v` | ALU | LDA/STA/ADD/SUB/AND + flag `zero` |
| `register_ac.v` | accumulator | registrador AC |
| `driver_inst.v` | driver | **mux** que coloca AC ou o dado lido no barramento (sintetizável) |
| `memory_inst.v` | memory | RAM 256×16 (síntese: leitura comb., escrita sínc.) + programa |

> Nota: o barramento usa um **mux** em vez de tri-state, para ser sintetizável
> na FPGA (FPGAs não têm tri-state interno).

## Formato das instruções

```text
[15:12] = opcode      [7:0] = endereço do operando
```

Opcodes:

```text
1 = LDA   AC = mem[addr]
2 = STA   mem[addr] = AC
3 = ADD   AC = AC + mem[addr]
4 = SUB   AC = AC - mem[addr]
5 = AND   AC = AC & mem[addr]
6 = JMP   PC = addr
7 = JZ    se (AC == 0) PC = addr
F = HLT   para a CPU
```

## I/O mapeado em memória

Dois endereços especiais ligam o programa ao mundo externo:

```text
0xF0  -> CHAVES (entrada)  : "LDA 0xF0" coloca o valor das chaves no AC
0xF1  -> LEDs   (saída)    : "STA 0xF1" mostra o AC nos LEDs
```

Isso é feito em `cpu_top.v`: ao ler o endereço `0xF0` o barramento recebe
`in_port`; ao escrever (`STA`) no endereço `0xF1` o valor é travado num
registrador que alimenta `out_port`.

## Programa atual (em `memory_inst.v`)

```text
ram[0] = 10F0  ; LDA 0xF0   -> AC = chaves
ram[1] = 20F1  ; STA 0xF1   -> LEDs = AC
ram[2] = 6000  ; JMP 0      -> repete para sempre
```

Resultado: os **LEDs seguem as chaves, mas passando pelo processador**
(executando LDA/STA/JMP). Há exemplos comentados no arquivo para mostrar a ALU
(ex.: `LEDs = chaves + constante`).

## Simulação (Vivado XSim)

1. Em *Simulation Sources*, deixe `tb_cpu_top` como topo.
2. **Run Simulation → Run Behavioral Simulation** → **Run All**.
3. O testbench muda `in_port` (chaves) e imprime no console; `out_port[3:0]`
   deve seguir `in_port[3:0]`.
4. Para ver na waveform, adicione de `uut`: `phase`, `pc/pc_addr`, `ir/opcode`,
   `ac/ac_out`, `out_port`, `in_port`.

## Execução na Zybo

Pinos (em `Zybo_Constraints.xdc`):

```text
clk      -> 125 MHz da placa (L16)
rst      -> BTN0 (R18)
sw[3:0]  -> SW0..SW3
led[3:0] -> LD0..LD3
```

Na placa: mova uma chave → o LED correspondente acende (o processador lê a
chave com `LDA` e escreve no LED com `STA`). Pressione **BTN0** para resetar o
processador.

### Opção A — pela interface do Vivado

1. Adicione todos os `componentes/*.v` como *design sources* e
   `Zybo_Constraints.xdc` como *constraint*.
2. No painel **Sources**, botão direito em `top` → **Set as Top**.
3. **Run Synthesis → Run Implementation → Generate Bitstream**.
4. **Open Hardware Manager → Open Target → Auto Connect**.
5. **Program Device** → selecione o `.bit` → **Program**.

### Opção B — por scripts (makefile + Tcl)

Na raiz do projeto (`Risc/`):

```sh
make build      # sintetiza, implementa e gera top.bit (CPU completa)
make program    # grava top.bit na placa (Zybo ligada via USB/JTAG)
make clean      # remove arquivos gerados
```

- `build.tcl` — projeto em memória; lê `top.v` + todos os módulos da CPU + o
  `.xdc`; roda `synth → opt → place → route → write_bitstream`.
- `program.tcl` — abre o hardware manager, conecta no JTAG e grava `top.bit`.
- `makefile` — atalhos `build` / `program` / `clean`.

Caminho do Vivado no makefile: `C:\Xilinx\Vivado\2024.2\bin\vivado.bat`
(formato Windows, pois o `make` no PowerShell roda as receitas pelo cmd.exe).
Para usar outro: `make VIVADO=vivado build`.

Equivalente sem make (PowerShell):

```powershell
& "C:\Xilinx\Vivado\2024.2\bin\vivado.bat" -mode batch -source build.tcl
& "C:\Xilinx\Vivado\2024.2\bin\vivado.bat" -mode batch -source program.tcl
```

## Pontos importantes

- Os arquivos `tb_*.v` **não** entram na síntese (apenas na simulação).
- A síntese usa `top` como topo; a simulação usa `tb_cpu_top`.
- O barramento é mux (sintetizável); não há tri-state interno.
- I/O é mapeado em memória: `0xF0` (chaves) e `0xF1` (LEDs).

# TESTE_DA_ZYBO

Projeto minimo para gerar o bitstream do processador na Zybo sem depender do arquivo `.xpr` do Vivado.

## Arquivos

- `top.v`: adapta os pinos fisicos da placa para o `processador_top`.
- `zybo.xdc`: liga `clk`, `sw`, `btn` e `led` aos pinos reais da Zybo.
- `build.tcl`: cria um projeto Vivado em memoria, adiciona os `.v`, sintetiza, implementa e gera `top.bit`.
- `program.tcl`: grava `top.bit` na placa.
- `makefile`: atalhos para `make build`, `make program` e `make clean`.

## Ligacoes

- `clk`: clock da Zybo.
- `btn[0]`: reset do processador.
- `sw[3:0]`: entrada baixa de `in_port`.
- `led[3:0]`: 4 bits baixos de `out_port`.

## Como usar

Na pasta deste README:

```sh
make build
make program
```

Ou diretamente:

```sh
vivado -mode batch -source build.tcl
vivado -mode batch -source program.tcl
```

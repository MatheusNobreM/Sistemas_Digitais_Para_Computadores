# =====================================================================
#  Makefile - build e gravacao na Zybo (pratica switches -> LEDs)
#
#  Uso (rode na raiz do projeto, no PowerShell ou cmd):
#     make build      -> gera top.bit
#     make program    -> grava top.bit na placa
#     make clean      -> remove arquivos gerados
#
#  Caminho do Vivado em formato Windows (cmd.exe entende).
#  Para sobrescrever:  make VIVADO=vivado build
# =====================================================================
PROJECT   = top
BITSTREAM = $(PROJECT).bit

VIVADO ?= C:\Xilinx\Vivado\2024.2\bin\vivado.bat

.PHONY: all build program clean

all: build

build:
	"$(VIVADO)" -mode batch -source build.tcl

program:
	"$(VIVADO)" -mode batch -source program.tcl

clean:
	-del /q $(BITSTREAM) *.jou *.log *.pb *.dcp *.rpt 2>nul
	-rmdir /s /q .Xil .cache 2>nul

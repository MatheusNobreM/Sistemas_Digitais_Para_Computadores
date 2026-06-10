PROJECT = top
BITSTREAM = $(PROJECT).bit

.PHONY: all build program clean

all: build

build:
	vivado -mode batch -source build.tcl

program:
	vivado -mode batch -source program.tcl

clean:
	rm -rf .Xil *.jou *.log *.pb *.cache usage_statistics_webtalk.* *.bit *.dcp *.rpt

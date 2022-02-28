out := out
includes := -I src/headers
files := src/*/main.cu

all:semi_interval alignment cpu

ls:
	@echo $(files)

%: ./src/%/main.cu
	nvcc -w $(includes) $< -o $(out)/$@

cl: 
	rm $(out)\*

cpu:
	g++ $(includes) src/cpu/main.cpp -o $(out)/cpu.exe

.PHONY: cl

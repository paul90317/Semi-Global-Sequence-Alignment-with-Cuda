out := out
includes := -I src/headers
files := src/*/main.cu

all:semi_interval.exe alignment.exe cpu.exe

test: semi_interval.exe alignment.exe cpu.exe

ls:
	@echo $(files)

%.exe:./src/%/main.cu
	nvcc -w $(includes) $< -o $(out)/$@

cl: 
	rm $(out)\* -rf

cpu.exe:
	g++ $(includes) src/cpu/main.cpp -o $(out)/cpu.exe

.PHONY: cl

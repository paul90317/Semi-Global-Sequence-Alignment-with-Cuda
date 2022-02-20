out := ../out
includes := -I headers
files := */main.cu

all:semi_interval.exe alignment.exe

ls:
	@echo $(files)

%.exe:./%/main.cu
	nvcc -w $(includes) $< -o $(out)/$@
	$(out)/$@

cl: 
	rm -rf $(out)/*

cpu.exe:
	g++ $(includes) cpu/main.cpp -o $(out)/cpu.exe
	$(out)/cpu.exe

.PHONY: cl

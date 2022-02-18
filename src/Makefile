out := ../out
includes := -I headers
files := */main.cu

ls:
	@echo $(files)

%.exe:./%/main.cu
	nvcc $(includes) $< -o $(out)/$@
	$(out)/$@

cl: 
	rm -rf $(out)/*

.PHONY: ls

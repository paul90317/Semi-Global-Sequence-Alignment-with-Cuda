workdir := ..
out := $(workdir)/out
includes := -I headers
run:
	nvcc $(includes) 2free/afg.cu -o $(out)/2free
	$(out)/2free

clean: 
	rm -rf *.obj
	rm -rf $(workdir)/out/*

.PHONY: run

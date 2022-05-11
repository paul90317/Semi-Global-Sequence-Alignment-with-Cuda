includes := -I src/headers

all:semi_interval.out alignment.out cpu.out

gpu_test:semi_interval.out alignment.out
	./gpu_test.sh

cpu_test:cpu.out
	./cpu_test.sh

clean_tasks:
	python3 scripts/clean.py

semi_interval.out: ./src/semi_interval/main.cu
	nvcc -w $(includes) $< -o $@

alignment.out: ./src/alignment/main.cu
	nvcc -w $(includes) $< -o $@

cpu.out: src/cpu/main.cpp
	nvcc -w $(includes) $< -o $@

clean:
	rm *.out

.PHONY: clean all clean_tasks cpu_test gpu_test

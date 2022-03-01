includes := -I src/headers

all:semi_interval.exe alignment.exe cpu.exe

gpu_test:semi_interval.exe alignment.exe
	python scripts\gpu_test.py

cpu_test:cpu.exe
	python scripts\cpu_test.py

clean_tasks:
	python scripts\clean.py

semi_interval.exe: ./src/semi_interval/main.cu
	nvcc -w $(includes) $< -o $@

alignment.exe: ./src/alignment/main.cu
	nvcc -w $(includes) $< -o $@

cpu.exe: src/cpu/main.cpp
	nvcc -w $(includes) $< -o $@

clean:
	del *.exe
	del *.exp
	del *.lib

.PHONY: clean

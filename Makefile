afgsrc:=src/afg/afg_gpu.cu
afgexe:=afg_gpu.exe

almsrc:=src/alm/alm.cu
almexe:=alm.exe

cpusrc:=src/cpu/afg_cpu.cpp
cpuexe:=afg_cpu.exe

timesrc:=src/time.cpp
timeexe:=time.exe

rdsrc:=src/rd.cpp
rdexe:=rd.exe

slicesrc:=src/slice.cpp
sliceexe:=slice.exe

appsrc:=src/app.cpp
appexe:=app.exe

checksrc:=src/checkalm.cpp
checkexe:=checkalm.exe

x:=res/x.txt
y:=res/y.txt
tmp:=res/tmp.txt
almout:=res/almout.txt

runall:$(timeexe) $(appexe) $(x) $(y) $(afgexe) $(sliceexe) $(almexe)
	$(timeexe) $(appexe) $(x) $(y) $(almout) $(tmp) $(afgexe) $(sliceexe) $(almexe)

runcpu: $(timeexe) $(cpuexe) $(x) $(y)
	$(timeexe) $(cpuexe) $(x) $(y) 
runafg: $(timeexe) $(afgexe) $(x) $(y) 
	$(timeexe) $(afgexe) $(x) $(y)
runalm: $(timeexe) $(almexe) $(x) $(yslice) $(almout)
	$(timeexe) $(almexe) $(x) $(y)
check: $(checkexe) $(almout)
	$(checkexe) $(almout)

$(x):$(rdexe)
	$(rdexe) $(x) 3600 $(y) 100000
$(y):$(rdexe)
	$(rdexe) $(x) 3600 $(y) 100000
$(almout): runall

$(rdexe):
	g++ $(rdsrc) -o $(rdexe)
$(timeexe):
	g++ $(timesrc) -o $(timeexe)
$(cpuexe):
	g++ $(cpusrc) -o $(cpuexe)
$(afgexe):
	nvcc $(afgsrc) -o $(afgexe)
$(almexe):
	nvcc $(almsrc) -o $(almexe)
$(sliceexe):
	g++ $(slicesrc) -o $(sliceexe)
$(appexe):
	g++ $(appsrc) -o $(appexe)
$(checkexe):
	g++ $(checksrc) -o $(checkexe)

clean:rmexe rmres

rmexe:
	rm *.exe
rmres:
	rm res/*
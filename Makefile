afgsrc:=src/afg/afg_gpu.cu
afgexe:=afg_gpu.exe

almsrc1:=src/alm1Dspace/alm.cu
almexe1:=alm1.exe

almsrc2:=src/alm2Dspace/alm.cu
almexe2:=alm2.exe

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

flatsrc:=src/flat.cpp
flatexe:=flat.exe

x:=res/x.txt
y:=res/y.txt
tmp:=res/tmp.txt
almout:=res/almout.txt

runall1:$(timeexe) $(appexe) $(afgexe) $(sliceexe) $(almexe1) $(checkexe)
	./$(timeexe) $(appexe) $(x) $(y) $(almout) $(tmp) $(afgexe) $(sliceexe) $(almexe1)
	./$(checkexe) $(almout) $(x) $(tmp)

runall2:$(timeexe) $(appexe) $(afgexe) $(sliceexe) $(almexe2) $(checkexe)
	./$(timeexe) $(appexe) $(x) $(y) $(almout) $(tmp) $(afgexe) $(sliceexe) $(almexe2)
	./$(checkexe) $(almout) $(x) $(tmp)

runcpu: $(timeexe) $(cpuexe) $(x) $(y)
	./$(timeexe) $(cpuexe) $(x) $(y) 

runafg: $(timeexe) $(afgexe) $(x) $(y) 
	./$(timeexe) $(afgexe) $(x) $(y)
random:$(rdexe)
	./$(rdexe) $(x) 3600 $(y) 100000

$(rdexe):
	g++ $(rdsrc) -o $(rdexe)
$(timeexe):
	g++ $(timesrc) -o $(timeexe)
$(cpuexe):
	g++ $(cpusrc) -o $(cpuexe)
$(afgexe):
	nvcc $(afgsrc) -o $(afgexe)
$(almexe2):
	nvcc $(almsrc2) -o $(almexe2)
$(almexe1):
	nvcc $(almsrc1) -o $(almexe1)
$(sliceexe):
	g++ $(slicesrc) -o $(sliceexe)
$(appexe):
	g++ $(appsrc) -o $(appexe)
$(checkexe):
	g++ $(checksrc) -o $(checkexe)
$(flatexe):
	g++ $(flatsrc) -o $(flatexe)

clean:rmexe rmres

rmexe:
	rm *.exe
	rm *.lib
	rm *.exp
	rm *.pdb
rmres:
	rm res/*
# Semi-Sequence-Alignment-with-Cuda  
## What I have done
As the topic, semi sequence alignment with cuda technique. However, I don't do this by one program but two.  
1. the program [semi_interval](./src/semi_interval/main.cu), will calculate out best score with semi x,y first, then generate x,y's semi inteval.  
2. the program [alignment](./src/semi_interval/main.cu), will align the sequence x,y with the interval, although this is global align, but we have semi interval to do this, so result will as same as just do local sequence alignment.  
## Config
You can edit config in [config.h](./src/headers/config.h), this config is a part of program, so it will optialize with compiler.  
In this file, you can edit output file location, cuda, sequence x,y's start and end is free or fixed and so on.
You need to change score matrix in [score.json](score.json), and execute command
```
python scripts\load_score_matrix.py
```
to generate `score.txt` in temp folder, this is the input of CUDA|CPP Programs.  
Or, you can also use command
```
make gpu_test
```  
to run all the thing you need to do.
## How to use  
just run
```
make
```
you can get all the CUDA|CPP program executable.
there are three program executable.
1. **`semi_interval.exe`**  
get the best interval, you need to config semi setting in [config.h](src/headers/config.h).  
**command:**  
`semi_interval.exe [x.txt] [t.txt] [best interval.txt] [score.txt]`  
    * `[x.txt] [y.txt]`: the files need to contain input sequence.  
    * `[best interval.txt]`: best intervals store in this file.
    * `[score.txt]`: score matrix store will be get from this file, see [config](##Config)
2. **`alignment.exe`**  
get alignment using the `[best interval.txt]` generated by `semi_interval.exe`, this is global alignment but using the interval in `[best interval.txt]`  
**command:**  
`alignment.exe [x.txt] [y.txt] [best interval.txt] [score.txt] [alignment.txt]`  
    * `[x.txt] [y.txt]`: the files need to contain input sequence.  
    * `[best interval.txt]`: best interval should be got in this file (only get first line (interval)).
    * `[score.txt]`: score matrix store will be get from this file, see [config](##Config)
    * `[alignment.txt]`: alignment will be stored in this file.
3. **`cpu.exe`**  
just for testing speed, only calculate and print out global sequence alignment score.  
**command:**  
`cpu.exe [x.txt] [y.txt] [score.txt]`  
    * `[x.txt] [y.txt]`: the files need to contain input sequence.  
    * `[score.txt]`: score matrix store will be get from this file, see [config](##Config)

You can alse run scipts
* `make cpu_test`  
just use cpu run global alignment score in tasks, there is no semi function, so it just let you can compare cpu's performance with gpu's or, the global alignment score is realy the same as the program run with cuda(set x,y's start,end to fixed).  
* `make gpu_test`  
calcuate best score and its interval with cuda, then generate best score's alignment with cuda and all interals generated by `semi_interval.exe`, and this program also check the alignments's socre.  
* `make clean_tasks`  
clean alignments in tasks  
* `make clean`  
clean *.exe  

Here is data structure
```txt
tasks
>---[hello world]
    >---x.txt
    >---y.txt
>---[fist alignment]
    >---x.txt
    >---y.txt
>---[second alignmet]
    >---x.txt
    >---y.txt
>---[alignment 3]
    >---x.txt
    >---y.txt
```
after command `make gpu_test`  
```txt
tasks
>---[hello world]
    >---x.txt
    >---y.txt
    >---out
        >---best.txt
        >---alm
            >---[intervals.txt]
>---[fist alignment]
    >---x.txt
    >---y.txt
    >---out
        >---best.txt
        >---alm
            >---[intervals.txt]
>---[second alignmet]
    >---x.txt
    >---y.txt
    >---out
        >---best.txt
        >---alm
            >---[intervals.txt]
>---[alignment 3]
    >---x.txt
    >---y.txt
    >---out
        >---best.txt
        >---alm
            >---[intervals.txt]
```
## Performance  
### imporve log
#### all
* coalescing  
I change the array storage to fit coalescing, the this improve the performace.  
#### semi_interval  
* reduce memory of afg_unit  
make #if to let memory of afg_unit reduce, the improve is crazy.  
#### alignment
* end point 2D alignment  
make more big end point to forbidden trivial calling gpu kernel when interval is too small.  

### comparison
```cmd
x: fixed start, fixed end, size= 16641
y: fixed start, fixed end, size=118436
```
#### Compare CPU and GPU
In this block, I will show the time in Global sequence alignment interval run by CPU and all version of GPU.
Runing by   | Branch  | Time 
--------------|:-----:|:----:
CPU(cpu.exe) | - | 65.37s 
GPU(semi_interval.exe) |no coalescing |  35.58s 
GPU(semi_interval.exe) | coalescing |  11.57s
GPU(semi_interval.exe) | reduce memory of afg_unit |  1.40s

### Compare alignment version
In this block, I will compare the time of all versions of Global sequence alignment in GPU (alignment.exe).
Branch|Time
:-----:|:----:
no coalescing | 40.35s
coalescing | 24.38s
end point 2D alignment(linked list stack) |17.28s
trace back end point (30000x30000)|11.67s

#### Compare Semi settings
In this block, I will compare with time of x,y sequence's semi setting in the program semi_interval.exe(running by GPU).
x start | x end | y start | y end |Time
:-----:|:-----:|:-----:|:-----:|:-----:
fixed|fixed|fixed|fixed|1.54s
free|free|fixed|fixed|4.14s
fixed|fixed|free|free|4.13s
free|free|free|free|7.07s

## Test  
### enviroment 
**`OS`** `win10`  
**`make`**  `choco`  
**`nvidia-smi`**  
```cmd
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 471.41       Driver Version: 471.41       CUDA Version: 11.4     |
|-------------------------------+----------------------+----------------------+
| GPU  Name            TCC/WDDM | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  NVIDIA GeForce ... WDDM  | 00000000:01:00.0 Off |                  N/A |
| N/A   59C    P8     8W /  N/A |    134MiB /  4096MiB |      0%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+
```
### result  
**`semi_interval.exe`**  
```txt
X sequence: ../res/x.txt , Global interval=[1, 16641]
Y sequence: ../res/y.txt , Global interval=[1, 118436]

Time taken: 1.40s
Best interval saved in: ../res/best.txt

Best score: -90273
score= -90273; x=[1, 16641]; y=[1, 118436]
```
**`cpu.exe`**
```txt
Time taken: 65.37s
Best global alignment score: -90273
```
**`alignment.exe`**
```txt
Load semi interval from ../res/best.txt , Index=0, Score=-90273
X sequence: ../res/x.txt , Semi interval=[1, 16641]
Y sequence: ../res/y.txt , Semi interval=[1, 118436]

Time taken: 11.67s
Best score: -90273
The score of alignment ../res/alignment.txt is -90273
```

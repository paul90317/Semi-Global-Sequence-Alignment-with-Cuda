# Semi Global Sequence Alignment with Cuda  
## What I have done
As the topic, I alse implement the local and global sequence alignment.  
However, I don't do this by one program but two.  
1. The program [`semi_interval`](./src/semi_interval/main.cu), will calculate best score with semi x and y first, then generate semi inteval of x and y.  
2. The program [`alignment`](./src/semi_interval/main.cu), will align the sequence x,y with the interval, although this is global align, but we use semi interval to do this, so result will as same as semi global sequence alignment.  
## Config
You can edit config in [`config.h`](./src/headers/config.h), this config is a part of program, so it will be optimized (*"optimized"* is my word, not *"compiler optimizing"*) with preprocessor , such as branch reducing, class member reducing, etc.  
In this file, you can edit cuda thread number per block, start and end of sequence x and y is free or fixed the datatype of score matrix and so on.

## Compile and Run   
### compile
```shell
make
```
> make the program.
```shell
make clean
```
> clean the program

### run
```shell
semi_interval.exe <x.txt> <y.txt> <best interval.txt> <score.txt>
```
> Get the best interval, you need to config semi setting and datatype of score matrix in [`config.h`](src/headers/config.h).  

* `<x.txt>` `<y.txt>` the files need to contain input sequence.  
* `<best interval.txt>` best intervals store in this file.
* `<score.txt>` score matrix store will be get from this file.  

***
```shell
alignment.exe <x.txt> <y.txt> <best interval.txt> <score.txt> <alignment.txt>
```
> Get alignment using the `<best interval.txt>` generated by `semi_interval.exe`, this is global alignment but using the interval in `<best interval.txt>`  
* `<x.txt> <y.txt>` the files need to contain input sequence.  
* `<best interval.txt>` best interval should be got in this file (only get first line (interval)).
* `<score.txt>` score matrix store will be get from this file.
* `<alignment.txt>` alignment will be stored in this file.  
***
```shell
cpu.exe <x.txt> <y.txt> <score.txt>`  
```
> Just for testing speed, only calculate and print out global sequence alignment score.  

* `<x.txt>` `<y.txt>` the files need to contain input sequence.  
* `<score.txt>` score matrix store will be get from this file.
## Input and Ouput File Format
### Score Matrix `<score.txt>` 
> Which stores the score matrix used in program `alignment.exe` and `semi_interval.exe`.  

***input format***
```txt
<number base>
<base> ...
<score matrix> ...
.
.
.
<gap>
<extension>
```
> `<base>` can be any `char` (including `space`), but can not be `newline`

***input example***  
```txt
4
ATGC
1 -5 -5 -1 
-5 1 -1 -5 
-5 -1 1 -5 
-1 -5 -5 1 
-2
-1
```
***
### Sequence `<x.txt>` `<y.txt>`  
> The file only contain `newline` and `<base>`, the program will ignore `newline` when read the sequence file.

***input example*** 
```txt
AATTCCGAT
AATTCGTT
TGGAAT
```
***
### Best Interval `<best interval.txt>`

***output format by*** *`semi_interval.exe`*
```txt
<best score> <x start> <x end> <y start> <y end>
.
.
.
```
***input format by*** *`alignment.exe`*
```txt
<best score> <x start> <x end> <y start> <y end>
```
> If there are multiple lines, only the first line is consumed by `alignment.exe`
***
### Alignment `<alignment.txt>` 

***output example***
```txt
- C
A A
T T
G -
C C
- C
```
## Python scripts
You can use my python scripts which calculate alignment automatically in a specific file structure. If you have many alignment to do, it's useful.  

### File structure
```shell
├───score.json
├───tasks
│   ├───100K-100K
│   │   └───x.txt
│   │   └───y.txt
│   ├───100K-10K
│   │   └───x.txt
│   │   └───y.txt
│   ├───10K-100K
│   │   └───x.txt
│   │   └───y.txt
│   ├───10K-10K
│   │   └───x.txt
│   │   └───y.txt
│   └───1K-1K
│   │   └───x.txt
│   │   └───y.txt
```
*after command `make gpu_test`*  

```shell
├───tasks
│   ├───100K-100K
│   │   └───out
│   │       └───best.txt
│   │       └───alm
│   │           └───...
│   ├───100K-10K
│   │   └───out
│   │       └───best.txt
│   │       └───alm
│   │           └───...
│   ├───10K-100K
│   │   └───out
│   │       └───best.txt
│   │       └───alm
│   │           └───...
│   ├───10K-10K
│   │   └───out
│   │       └───best.txt
│   │       └───alm
│   │           └───...
│   └───1K-1K
│   │   └───out
│   │       └───best.txt
│   │       └───alm
│   │           └───...
```
> The folder `alm/` contains alignments `<alignment.txt>` generated from `alignment.exe` 

> The file `best.txt` is the file which stores the best intervals generated from `semi_interval.exe`
### Commands
```shell
make cpu_test
```
> Just use CPU run global alignment score in tasks, there is no semi function, so it just let you can compare the performance of CPU with that of GPU or, the global alignment score should be as same as the program run with CUDA (set start and end of x and y to fixed).  
```shell
make gpu_test
```
> Calcuate best scores and its intervals by `semi_interval.exe`, then run `alignemnt.exe` generate alignments of the intervals generated by `semi_interval.exe`.  
```shell
make clean_tasks
```
> clean alignments in tasks  
***
### Score Matrix `score.json`  
> This is very important, instead of `score.txt`, python scripts only allow `score.json`, but I think `score.json` is easier to edit.

*example for DNA*
```json
{
    "chars":["A","T","G","C"],
    "matrix":[
        [1,-1,-1,-1],
        [-1,1,-1,-1],
        [-1,-1,1,-1],
        [-1,-1,-1,1]
    ],
    "gap":-2,
    "extension":-1
}
```
*example for a-z, A-Z and space*
```json
{
    "chars":[
        {
            "l":"a",
            "r":"z"
        },
        {
            "l":"A",
            "r":"Z"
        },
        " "
    ],
    "matrix":{
        "match":1,
        "miss":-1
    },
    "gap":-2,
    "extension":-1
}
```

## Requirements
* MSVC `19.29.30143 for x64`
* CUDA `11.4`
* NVIDIA-SMI `471.41`
* Operating System `Windows 11`
* Make `GNU Make 4.3`
* Python `3.10.4`

## Result  
#### `semi_interval.exe`  
```shell
X sequence: ../res/x.txt , Global interval=[1, 16641]
Y sequence: ../res/y.txt , Global interval=[1, 118436]

Time taken: 1.40s
Best interval saved in: ../res/best.txt

Best score: -90273
score= -90273; x=[1, 16641]; y=[1, 118436]
```
#### `cpu.exe`
```shell
Time taken: 65.37s
Best global alignment score: -90273
```
#### `alignment.exe`
```shell
Load semi interval from ../res/best.txt , Index=0, Score=-90273
X sequence: ../res/x.txt , Semi interval=[1, 16641]
Y sequence: ../res/y.txt , Semi interval=[1, 118436]

Time taken: 11.67s
Best score: -90273
The score of alignment ../res/alignment.txt is -90273
```
> Aside from generating the alignment, the program also checks whether or not the score is as same as that saved in `<best interval.txt>`.
## Performance  
```shell
x: fixed start, fixed end, size= 16641
y: fixed start, fixed end, size=118436
```
### Compare CPU with GPU
Runing by   | Branch  | Time 
--------------|:-----:|:----:
CPU(cpu.exe) | - | 65.37s 
GPU(semi_interval.exe) |no coalescing |  35.58s 
GPU(semi_interval.exe) | coalescing |  11.57s
GPU(semi_interval.exe) | reduce memory of afg_unit |  1.40s

### Compare different versions of `alignment.exe` 
Branch|Time
:-----:|:----:
no coalescing | 40.35s
coalescing | 24.38s
end point 2D alignment(linked list stack) |17.28s
trace back end point (30000x30000)|11.67s

### Compare different Semi settings of `semi_interval.exe`
x start | x end | y start | y end |Time
:-----:|:-----:|:-----:|:-----:|:-----:
fixed|fixed|fixed|fixed|1.54s
free|free|fixed|fixed|4.14s
fixed|fixed|free|free|4.13s
free|free|free|free|7.07s
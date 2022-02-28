
#include <iostream>
#include "test_time.h"
#include "utils.cuh"

#define THREADS 64
#define BLOCKS 2048
#define TIME 300000
#define COUNT (THREADS*BLOCKS)
__global__ void adder(int* a,int *b,int *c){
    int tid=TID;
    a[tid]+=b[tid]+c[tid];
}

__global__ void loop_adder(int* a,int *b,int *c){
    int tid=TID;
    for(int i=0;i<TIME;i++){
        a[tid]+=b[tid]+c[tid];
    }
}

int main(){
    int *a,*b,*c;
    cudaMalloc(&a,sizeof(int)*COUNT);
    cudaMalloc(&b,sizeof(int)*COUNT);
    cudaMalloc(&c,sizeof(int)*COUNT);
    time_start();
    for(int i=0;i<TIME;i++){
        adder _kernel(BLOCKS,THREADS)(a,b,c);
    }
    //loop_adder _kernel(BLOCKS,THREADS)(a,b,c);
    time_end();
}
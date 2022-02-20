
#include <iostream>
#include "test_time.h"
#include "utils.cuh"

#define THREADS 64
#define BLOCKS 2048
#define TIME 300000
#define COUNT (THREADS*BLOCKS)

__global__ void sadder(int* a,int *b,int *c){
    int gid=TID;
    int tid=threadIdx.x;
    __shared__ static int sb[THREAD_SIZE];
    __shared__ static int sc[THREAD_SIZE];
    sb[tid]=b[gid];
    sc[tid]=c[gid];
    a[gid]=sb[tid]*sc[tid];
}
__global__ void adder(int* a,int *b,int *c){
    int tid=TID;
    a[tid]=b[tid]*c[tid]+c[tid]*(b[tid]+1);
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
        sadder _kernel(BLOCKS,THREADS)(a,b,c);
    }
    //loop_adder _kernel(BLOCKS,THREADS)(a,b,c);
    time_end();
}
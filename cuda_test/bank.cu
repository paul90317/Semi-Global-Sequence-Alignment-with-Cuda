
#include <iostream>
#include "test_time.h"
#include "utils.cuh"

#define THREADS 64
#define BLOCKS 2048
#define TIME 300000
#define COUNT (THREADS*BLOCKS)

__global__ void adder1(){//bank conflict
    int gid=TID;
    int tid=threadIdx.x;
    __shared__ static int m[THREAD_SIZE][4];
    m[tid][0]=m[tid][1]+m[tid][2]+m[tid][3];
}
__global__ void adder2(){//no bank conflict, but not continue
    int gid=TID;
    int tid=threadIdx.x;
    __shared__ static int m[4][THREAD_SIZE];
    m[0][tid]=m[1][tid]+m[2][tid]+m[3][tid];
}
__global__ void adder3(){//no bank conflict
    int gid=TID;
    int tid=threadIdx.x;
    __shared__ static int m[THREAD_SIZE][5];
    m[tid][0]=m[tid][1]+m[tid][2]+m[tid][3];
}
int main(){
    time_start();
    for(int i=0;i<TIME;i++){
        adder3 _kernel(BLOCKS,THREADS)();
    }
    time_end();
}
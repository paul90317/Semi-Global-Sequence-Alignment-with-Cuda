
#include <iostream>
#include "test_time.h"
#include "utils.cuh"

#define COUNT 1000000
#define TIME 100000
#define PRE_BRANCH (COUNT/3)
//這是為了要確定如果先 return 就不需要進 warp
__global__ void _move(int* a,int *b,int count){
    int tid=TID;
    if(tid>=PRE_BRANCH)return;
    a[tid]=b[tid];
}
void move(int* a,int* b,int count){
    int nb,nt;
    thread_assign(count,&nb,&nt);
    _move _kernel(nb,nt)(a,b,count);
}

int main(){
    int *a,*b;
    cudaMalloc(&a,sizeof(int)*COUNT);
    cudaMalloc(&b,sizeof(int)*COUNT);
    time_start();
    for(int i=0;i<TIME;i++){
        move(a,b,COUNT);
    }
    time_end();
}
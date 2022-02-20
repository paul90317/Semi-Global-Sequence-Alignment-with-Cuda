
#include <iostream>
#include "test_time.h"
#include "utils.cuh"

#define COUNT 1000000
#define TIME 100000
__global__ void _move(int* a,int *b,int count){
    int tid=TID;
    if(tid>=count)return;
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
        //cudaMemcpy(a,b,sizeof(int)*COUNT,cudaMemcpyDeviceToDevice);
    }
    time_end();
}

#include <iostream>
#include "test_time.h"
#include "utils.cuh"

#define COUNT 1000000
#define TIME 100000
//#define dimcf(i,j) ((i)+(j)*COUNT)
#define dimcf(i,j) (3*(i)+(j))
__global__ void _cal(int* M,int count){
    int tid=TID;
    if(tid>=count)return;
    M[dimcf(tid,0)]=M[dimcf(tid,1)]+M[dimcf(tid,2)];
}
void cal(int* M,int count){
    int nb,nt;
    thread_assign(count,&nb,&nt);
    _cal _kernel(nb,nt)(M,count);
}

int main(){
    int *M;
    cudaMalloc(&M,sizeof(int)*COUNT*3);
    time_start();
    for(int i=0;i<TIME;i++){
        cal(M,COUNT);
    }
    time_end();
}
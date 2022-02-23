#ifndef MEM_CONTROLLER
#define MEM_CONTROLLER

#include "utils.cuh"

namespace mem_controller{
    __device__ byte mem[ALM_END_POINT_SIZE][ALM_MEM_STACK_SIZE];
    __device__ int back[ALM_END_POINT_SIZE];
    __device__ void* new_node(int tid,int size){
        void* t=&(mem[tid][back[tid]]);
        back[tid]+=size;
        return t;
    }
    __global__ void _clear(){
        int tid=TID;
        if(tid>=ALM_END_POINT_SIZE)return;
        back[tid]=0;
    }
    __host__ void clear(){
        int nb,nt;
        thread_assign(ALM_END_POINT_SIZE,&nb,&nt);
        _clear _kernel(nb,nt)();
    }
};

#endif
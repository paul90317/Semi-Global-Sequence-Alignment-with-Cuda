#ifndef MACRO_H
#define MACRO_H
#include "config.h"
#include "afg_unit.cuh"
#include "layout.cuh"

__device__ inline void update_score(res_unit& now,int xid,int yid,res_unit*best_stack,int *bs_count,datatype* best_score){
#if X_FREE_END
    now.xend=xid;
#endif
#if Y_FREE_END
    now.yend=yid;
#endif
    if(now.score>(*best_score)+BEST_DIFF){
        *bs_count=0;
    }
    if(now.score>=(*best_score)-BEST_DIFF){
    #if (SAFE_PUSH_MODE)
        best_stack[(*bs_count)]=now;
        if(*bs_count<BEST_STACK_SIZE)(*bs_count)++;
    #else
        best_stack[(*bs_count)++]=now;
    #endif
        *best_score=max2((*best_score),now.score);
    }
}

#define Y_NOT_END(idy,xsize,ysize) (((idy)-(xsize)-1)<=(ysize))
#define START_MODE (X_FREE_START+Y_FREE_START*2)
#define END_MODE (X_FREE_END+Y_FREE_END*2)

template<typename T>
void assign_single(T* g_dst,T c_value){
    cudaMemcpy(g_dst,&c_value,sizeof(T),cudaMemcpyHostToDevice);
}
namespace protected_space{
    template<typename T>
    __global__ void _assign_arr(T* g_arr,T value,int count){
        int tid=TID;
        if(tid<count)g_arr[tid]=value;
    }
}
template<typename T>
inline void assign_arr(T* g_arr,T value,int count){
    int nb,nt;
    thread_assign(count,&nb,&nt);
    protected_space::_assign_arr _kernel(nb,nt)(g_arr,value,count);
}
#endif
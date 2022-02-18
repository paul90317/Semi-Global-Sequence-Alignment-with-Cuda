#ifndef MACRO_H
#define MACRO_H
#include "config.cuh"
#include "afg_unit.cuh"

__device__ inline void update_score(res_unit& now,int& xid,int& yid,res_unit*best_stack,int *bs_count){
    now.xend=xid;
    now.yend=yid;
    if(now.score>best_score+BEST_DIFF){
        *bs_count=0;
    }
    if(now.score>=best_score-BEST_DIFF){
    #if (SAFE_PUSH_MODE)
        if(*bs_count<BEST_STACK_SIZE)best_stack[(*bs_count)++]=now;
    #else
        best_stack[(*bs_count)++]=now;
    #endif
        best_score=max2(best_score,now.score);
    }
}
#define Y_NOT_END(idy,xsize,ysize) (((idy)-(xsize)-1)<=(ysize))
#define START_MODE (X_FREE_START+Y_FREE_START*2)

#endif
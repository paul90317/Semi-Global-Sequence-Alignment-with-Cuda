#ifndef LAYOUT_H
#define LAYOUT_H
#include "comm.cuh"
#include "afg_unit.cuh"
#include <fstream>
#include <cstdlib>
#include <iomanip>

void show_best_and_output_file(char* filename,res_unit_end* bests,int count,int xsize,int ysize,datatype best_score){
    std::fstream fs;
    fs<<std::fixed<<std::setprecision(FLOAT_PRECISION);
    fs.open(filename,std::ios::out);
    int k=0;
    for(int i=0;i<count;i++){
        res_unit_end best=bests[i];
        datatype score=best.score;
        if(score<best_score-BEST_DIFF)continue;
        int xstart=1;
        int ystart=1;
        int xend=xsize;
        int yend=ysize;
    #if X_FREE_START
        xstart=best.xstart;
    #endif
    #if X_FREE_END
        xend=best.xend;
    #endif
    #if Y_FREE_START
        ystart=best.ystart;
    #endif
    #if Y_FREE_END
        yend=best.yend;
    #endif
        if(k<BEST_SHOW_NUMBER){
            std::cout<<"inteval: "<<"X=["<<xstart<<", "<<xend<<"] Y=["<<ystart<<", "<<yend<<"]\n";
            std::cout<<" - score: "<<score<<"\n";
        }
        if(k==BEST_SHOW_NUMBER)std::cout<<"...\n";
        k++;
        
        fs<<score<<" "<<xstart<<" "<<xend<<" "<<ystart<<" "<<yend<<"\n";
    }
    fs.close();
}
void show_best_and_output_file(char* filename,res_unit_end best,int xsize,int ysize){
    std::fstream fs;
    fs<<std::fixed<<std::setprecision(FLOAT_PRECISION);
    fs.open(filename,std::ios::out);
    datatype score=best.score;
    int xstart=1;
    int ystart=1;
    int xend=xsize;
    int yend=ysize;
#if X_FREE_START
    xstart=best.xstart;
#endif
#if X_FREE_END
    xend=best.xend;
#endif
#if Y_FREE_START
    ystart=best.ystart;
#endif
#if Y_FREE_END
    yend=best.yend;
#endif
    std::cout<<"inteval: "<<"X=["<<xstart<<", "<<xend<<"] Y=["<<ystart<<", "<<yend<<"]\n";
    std::cout<<" - score: "<<score<<"\n";
    fs<<score<<" "<<xstart<<" "<<xend<<" "<<ystart<<" "<<yend<<"\n";
    fs.close();
}

int interval_result_from_gup(res_unit_end** C_dst,res_unit_end* G_src,int* G_sz){
    int csize;
    cudaMemcpy(&csize,G_sz,sizeof(int),cudaMemcpyDeviceToHost);
    *C_dst=(res_unit_end*)malloc(sizeof(res_unit_end)*(csize));
    cudaMemcpy(*C_dst,G_src,sizeof(res_unit_end)*(csize),cudaMemcpyDeviceToHost);
    return csize;
}

datatype interval_result_from_gup(res_unit_end** C_dst,res_unit_end* G_src,int count){
    *C_dst=(res_unit_end*)malloc(sizeof(res_unit_end)*count);
    cudaMemcpy(*C_dst,G_src,sizeof(res_unit_end)*count,cudaMemcpyDeviceToHost);
    datatype best=NEG_INF;
    for(int i=0;i<count;i++){
        best=max2(best,(*C_dst)[i].score);
    }
    return best;
}

template<typename T>
void assign_single(T* g_dst,T c_value){
    cudaMemcpy(g_dst,&c_value,sizeof(T),cudaMemcpyHostToDevice);
}
namespace protected_space{
    __global__ void _assign_value2res(res_unit* g_arr,datatype value,int count){
        int tid=TID;
        if(tid<count)g_arr[tid].score=value;
    }
    __global__ void _assign_afg(afg_unit* g_arr,afg_unit value,int count){
        int tid=TID;
        if(tid<count)g_arr[tid]=value;
    }
}

inline void assign_value2res(res_unit_end* g_arr,datatype value,int count=1){
    int nb,nt;
    thread_assign(count,&nb,&nt);
    protected_space::_assign_value2res _kernel(nb,nt)(g_arr,value,count);
}

inline void assign_afg(afg_unit* g_arr,afg_unit value,int count=1){
    int nb,nt;
    thread_assign(count,&nb,&nt);
    protected_space::_assign_afg _kernel(nb,nt)(g_arr,value,count);
}

__device__ inline void update_score(res_unit_end& now,res_unit_end*best_stack,int *bs_count,datatype* best_score){
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

#endif
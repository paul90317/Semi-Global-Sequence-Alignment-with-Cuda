#ifndef LAYOUT_H
#define LAYOUT_H
#include "config.h"
#include "afg_unit.cuh"
#include <fstream>
#include <cstdlib>

void show_best_and_output_file(char* filename,res_unit_end* bests,int count,int xsize,int ysize,datatype best_score){
    std::fstream fs;
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
        if(k<BEST_SHOW_NUMBER)std::cout<<"score= "<<score<<"; x=["<<xstart<<", "<<xend<<"]; y=["<<ystart<<", "<<yend<<"]\n";
        if(k==BEST_SHOW_NUMBER)std::cout<<"...\n";
        k++;
        
        fs<<score<<" "<<xstart<<" "<<xend<<" "<<ystart<<" "<<yend<<"\n";
    }
    fs.close();
}
void show_best_and_output_file(char* filename,res_unit_end best,int xsize,int ysize){
    std::fstream fs;
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
    std::cout<<"score= "<<score<<"; x=["<<xstart<<", "<<xend<<"]; y=["<<ystart<<", "<<yend<<"]\n";
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

#endif
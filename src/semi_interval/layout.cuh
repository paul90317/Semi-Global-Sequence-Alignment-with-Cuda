#ifndef LAYOUT_H
#define LAYOUT_H
#include "config.cuh"
#include "afg_unit.cuh"
#include <fstream>
#include <cstdlib>

void show_best_and_output_file(res_unit* bests,int count,int xsize,int ysize){
    std::fstream fs;
    fs.open(filename_best_score_interval,std::ios::out);
    for(int i=0;i<count;i++){
        res_unit best=bests[i];
        datatype score=best.score;
        int xstart=X_FREE_START?best.xstart:1;
        int ystart=Y_FREE_START?best.ystart:1;
        int xend=X_FREE_END?best.xend:xsize;
        int yend=Y_FREE_END?best.yend:ysize;
        std::cout<<"score= "<<score<<"; x=["<<xstart<<", "<<xend<<"]; y=["<<ystart<<", "<<yend<<"]\n";
        fs<<score<<" "<<xstart<<" "<<xend<<" "<<ystart<<" "<<yend<<"\n";
    }
    fs.close();
}
void show_best_and_output_file(res_unit best,int xsize,int ysize){
    std::fstream fs;
    fs.open(filename_best_score_interval,std::ios::out);
    datatype score=best.score;
    int xstart=X_FREE_START?best.xstart:1;
    int ystart=Y_FREE_START?best.ystart:1;
    int xend=X_FREE_END?best.xend:xsize;
    int yend=Y_FREE_END?best.yend:ysize;
    std::cout<<"score= "<<score<<"; x=["<<xstart<<", "<<xend<<"]; y=["<<ystart<<", "<<yend<<"]\n";
    fs<<score<<" "<<xstart<<" "<<xend<<" "<<ystart<<" "<<yend<<"\n";
    fs.close();
}
__device__ datatype best_score=NEG_INF;

int interval_result_from_gup(res_unit** C_dst,res_unit* G_src,int* G_sz){
    int csize;
    cudaMemcpy(&csize,G_sz,sizeof(int),cudaMemcpyDeviceToHost);
    *C_dst=(res_unit*)malloc(sizeof(res_unit)*(csize));
    cudaMemcpy(*C_dst,G_src,sizeof(res_unit)*(csize),cudaMemcpyDeviceToHost);
    return csize;
}

#endif
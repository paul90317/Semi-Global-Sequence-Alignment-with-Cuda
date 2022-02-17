#ifndef LAYOUT_H
#define LAYOUT_H
#include "config.cuh"
#include "afg_unit.cuh"
#include <fstream>

void show_best_and_output_file(res_unit best,int xsize,int ysize){
    datatype score=best.score;
    int xstart=X_FREE_START?best.xstart:1;
    int ystart=Y_FREE_START?best.ystart:1;
    int xend=X_FREE_END?best.xend:xsize;
    int yend=Y_FREE_END?best.yend:ysize;
    std::cout<<"score= "<<score<<"; x=["<<xstart<<", "<<xend<<"]; y=["<<ystart<<", "<<yend<<"]\n";
    std::fstream fs;
    fs.open(filename_best_score_interval,std::ios::out);
    fs<<score<<" "<<xstart<<" "<<xend<<" "<<ystart<<" "<<yend;
    fs.close();
}   

#endif
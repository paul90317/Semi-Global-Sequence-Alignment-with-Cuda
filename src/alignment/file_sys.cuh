#ifndef FILE_SYS_H
#define FILE_SYS_H
#include <iostream>
#include <fstream>
#include <cstdlib>
#include "utils.cuh"

__host__ bool load_file(int** p_gx,int** p_x,const char* filename,int l,int r){
    FILE* f=fopen(filename,"r");
    if(f==NULL)return false;
    int sz=r-l+2;
    int* x_int=oalloc<int>(sz);
    x_int[0]=0;
    int j=1;
    for(int i=1;i<=r;){
        char c=getc(f);
        if(c==EOF)return false;
        if((c>'z'||c<'a')&&(c<'A'||c>'Z')&&(c<'0'||c>'9'))continue;
        if(i>=l)x_int[j++]=mapping_Char(c);
        i++;
    }
    fclose(f);
    cudaMalloc(p_gx,sizeof(int)*sz);
    cudaMemcpy(*p_gx,x_int,sizeof(int)*sz,cudaMemcpyHostToDevice);
    *p_x=x_int;
    return true;
}

__host__ bool load_best_interval(datatype* score,int* xl,int* xr,int* yl,int* yr){
    std::fstream fs;
    fs.open(filename_best_score_interval,std::ios::in);
    if(!fs)return false;
    for(int i=0;i<DEFAULT_INTERVAL_INDEX+1;i++)
        fs>>*score>>*xl>>*xr>>*yl>>*yr;
    fs.close();
    return true;
}

#endif
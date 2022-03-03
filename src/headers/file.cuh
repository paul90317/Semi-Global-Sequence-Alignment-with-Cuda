#ifndef FILE_H
#define FILE_H
#include <iostream>
#include <fstream>
#include <cstdlib>
#include "utils.cuh"

__host__ bool load_file(byte** p_gx,int* xsize,const char* filename){
    FILE* file=fopen(filename,"r");
    if(file==NULL)return false;
    fseek(file,0,SEEK_END);
    *xsize=ftell(file);
    fseek(file,0,SEEK_SET);
    byte* x_int=oalloc<byte>(*xsize+1);
    x_int[0]=0;
    int j=0;
    char c;
    while(c=my_get_ch(file),c!=EOF){
        byte b=mapping_Char(c);
        if(b==(byte)-1){
            printf("Error: Char [%c] not found!!\n",c);
            exit(0);
        }
        x_int[j+1]=b;
        j++;
    }
    *xsize=j;
    cudaMalloc(p_gx,sizeof(byte)*(*xsize+1));
    cudaMemcpy(*p_gx,x_int,sizeof(byte)*(*xsize+1),cudaMemcpyHostToDevice);
    free(x_int);
    fclose(file);
    return true;
}

__host__ bool load_file(byte** p_gx,byte** p_x,const char* filename,int l,int r){
    FILE* f=fopen(filename,"r");
    if(f==NULL)return false;
    int sz=r-l+2;
    byte* x_int=oalloc<byte>(sz);
    x_int[0]=0;
    int j=1;
    for(int i=1;i<=r;){
        char c=my_get_ch(f);
        if(c==EOF)return false;
        byte b=mapping_Char(c);
        if(b==(byte)-1)return false;
        if(i>=l)
            x_int[j++]=b;
        i++;
    }
    fclose(f);
    cudaMalloc(p_gx,sizeof(byte)*sz);
    cudaMemcpy(*p_gx,x_int,sizeof(byte)*sz,cudaMemcpyHostToDevice);
    *p_x=x_int;
    return true;
}

__host__ bool load_best_interval(char* filename,datatype* score,int* xl,int* xr,int* yl,int* yr){
    std::fstream fs;
    fs.open(filename,std::ios::in);
    if(!fs)return false;
    for(int i=0;i<DEFAULT_INTERVAL_INDEX+1;i++)
        fs>>*score>>*xl>>*xr>>*yl>>*yr;
    fs.close();
    return true;
}

#endif
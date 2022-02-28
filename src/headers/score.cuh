
#ifndef SCORE_H
#define SOCRE_H
#include "config.h"
#include <fstream>
#ifndef CPU
#include "utils.cuh"
#endif


namespace score{
#ifndef CPU
    __device__ datatype* gscore_matrix;
    __device__ int n_device;
    __device__ datatype g_device;
    __device__ datatype e_device;
    __global__ void _gscore_matrix_load(datatype* t,int n,int g,int e){
        gscore_matrix=t;
        n_device=n;
        g_device=g;
        e_device=e;
    }
#endif
    bool loaded=false;
    char* Char_map;
    datatype* score_matrix;
    int n_host;
    datatype g_host;
    datatype e_host;
    bool load(char* filename){//一定要做一次，將計分數導入 GPU 記憶體
        if(!loaded){
            char buf[10000];
            std::fstream fs;
            fs.open(filename,std::ios::in);
            if(!fs)return false;
            int n;
            fs>>n;
            Char_map=(char*)malloc(sizeof(char)*(n+1));
            Char_map[0]='-';
            char* pch = strtok (buf," \r\n");
            for(int i=1;i<=n;i++){
                fs>>Char_map[i];
            }
            score_matrix=(datatype*)malloc(sizeof(datatype)*(n+1)*(n+1));
            for(int j=0;j<=n;j++){
                score_matrix[j]=NEG_INF;
            }
            for(int i=1;i<=n;i++){
                score_matrix[(n+1)*i]=NEG_INF;
                for(int j=1;j<=n;j++){
                    fs>>score_matrix[(n+1)*i+j];
                }
            }
            fs>>g_host;
            fs>>e_host;
            n_host=++n;
        #ifndef CPU
            datatype *t1;
            int sz=sizeof(datatype)*(n+1)*(n+1);
            cudaMalloc(&t1,sz);
            cudaMemcpy(t1,score_matrix,sz,cudaMemcpyHostToDevice);
            _gscore_matrix_load<<<1,1>>>(t1,n,g_host,e_host);
            loaded=true;
        #endif
        }
        return true;
    }
}


#endif
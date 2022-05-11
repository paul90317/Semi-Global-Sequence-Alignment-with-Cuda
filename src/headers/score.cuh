#ifndef SCORE_H
#define SCORE_H

#include "mymacros.h"

namespace score{
    char* Char_map;
    datatype* score_matrix;
    int n_host;
    datatype g_host;
    datatype e_host;
#ifndef CPU
    __device__ datatype* gscore_matrix;
    __device__ byte n_device;
    __device__ datatype g_device;
    __device__ datatype e_device;
    __global__ void _gscore_matrix_load(datatype* t,int n,datatype g,datatype e){
        gscore_matrix=t;
        n_device=n;
        g_device=g;
        e_device=e;
    }
    __device__ inline datatype match(byte i,byte j){
        return gscore_matrix[score::n_device*i+j];
    }
#else
    datatype match(byte i,byte j){
        return score_matrix[score::n_host*i+j];
    }
#endif
    bool load(char* filename){//一定要做一次，將計分數導入 GPU 記憶體
        double temp;
        char buf[10000];
        std::fstream fs;
        fs.open(filename,std::ios::in);
        if(!fs)return false;
        int n;
        fs>>n;
        fs.getline(buf,9999);
        fs.getline(buf+1,9998);
        Char_map=(char*)malloc(sizeof(char)*(n+1));
        Char_map[0]='-';
        for(int i=1;i<=n;i++){
            Char_map[i]=buf[i];
        }
        score_matrix=(datatype*)malloc(sizeof(datatype)*(n+1)*(n+1));
        for(int j=0;j<=n;j++){
            score_matrix[j]=NEG_INF;
        }
        for(int i=1;i<=n;i++){
            score_matrix[(n+1)*i]=NEG_INF;
            for(int j=1;j<=n;j++){
                fs>>temp;
                score_matrix[(n+1)*i+j]=temp;
            }
        }
        fs>>temp;
        g_host=temp;
        fs>>temp;
        e_host=temp;
        n_host=n+1;
    #ifndef CPU
        datatype *t1;
        int sz=sizeof(datatype)*(n+1)*(n+1);
        cudaMalloc(&t1,sz);
        cudaMemcpy(t1,score_matrix,sz,cudaMemcpyHostToDevice);
        _gscore_matrix_load _single(t1,n_host,g_host,e_host);
    #endif
        return true;
    }
    inline byte char2byte(char c){
        for(byte i=0;i<score::n_host;i++){
            if(c==score::Char_map[i])return i;
        }
        return -1;
    }
}


#endif
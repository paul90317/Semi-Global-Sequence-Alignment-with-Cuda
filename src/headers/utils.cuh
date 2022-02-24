#ifndef UTILS_H
#define UTILS_H
#include "config.h"
#include "stdlib.h"
#include "utils.h"
#define TID (blockDim.x*blockIdx.x+threadIdx.x)

#define __all__ __device__ __host__
#define _single <<<1,1>>>
#define _kernel(nb,nt) <<<(nb),(nt)>>>
__host__ int mapping_Char(char c);

__host__ bool load_file(int** p_gx,int* xsize,const char* filename){
    FILE* file=fopen(filename,"r");
    if(file==NULL)return false;
    fseek(file,0,SEEK_END);
    *xsize=ftell(file);
    fseek(file,0,SEEK_SET);
    int* x_int=oalloc<int>(*xsize+1);
    x_int[0]=0;
    int j=0;
    char c;
    while(c=getc(file),c!=EOF){
        if((c>'z'||c<'a')&&(c<'A'||c>'Z')&&(c<'0'||c>'9'))continue;
        x_int[j+1]=mapping_Char(c);
        j++;
    }
    *xsize=j;
    cudaMalloc(p_gx,sizeof(int)*(*xsize+1));
    cudaMemcpy(*p_gx,x_int,sizeof(int)*(*xsize+1),cudaMemcpyHostToDevice);
    free(x_int);
    fclose(file);
    return true;
}
namespace protected_space{
    template<typename T>
    __global__ void _cudaObjset(T* arr,T& value,int count){
        int tid=TID;
        if(tid<count)
            arr[tid]=value;
    }
    __device__ datatype* gscore_matrix;
    bool loaded=false;
    __global__ void _gscore_matrix_load(datatype* t){
        protected_space::gscore_matrix=t;
    }
}

__host__ void gscore_matrix_load(){//一定要做一次，將計分數導入 GPU 記憶體
    if(!protected_space::loaded){
        datatype *t1;
        int sz=CHAR_NUMBER*CHAR_NUMBER*sizeof(datatype);
        datatype *t2=(datatype*)protected_space::score_matrix;
        cudaMalloc(&t1,sz);
        cudaMemcpy(t1,t2,sz,cudaMemcpyHostToDevice);
        protected_space::_gscore_matrix_load<<<1,1>>>(t1);
        protected_space::loaded=true;
    }
}

__host__ int thread_assign(int size,int* nblock,int*nthread){
    *nthread=min(size,THREAD_SIZE);
    *nblock=(size/THREAD_SIZE)+((size%THREAD_SIZE)>0);
    return (*nblock)*(*nthread);
}

namespace protected_space{
    __global__ void _addr_assign(void** dst,void* value){
        *dst=value;
    }
}

inline void addr_assign(void** gdst,void* gvalue){
    int nb,nt;
    protected_space::_addr_assign _single(gdst,gvalue);
}
#endif
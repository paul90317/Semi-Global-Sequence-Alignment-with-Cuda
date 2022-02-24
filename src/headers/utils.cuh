#ifndef UTILS_H
#define UTILS_H
#include "config.h"
#include "stdlib.h"
#include "utils.h"
#include "file.cuh"
#define TID (blockDim.x*blockIdx.x+threadIdx.x)

#define __all__ __device__ __host__
#define _single <<<1,1>>>
#define _kernel(nb,nt) <<<(nb),(nt)>>>

namespace protected_space{
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
        protected_space::_gscore_matrix_load _single(t1);
        protected_space::loaded=true;
    }
}

__host__ int thread_assign(int size,int* nblock,int*nthread){
    *nthread=min(size,THREAD_SIZE);
    *nblock=(size/THREAD_SIZE)+((size%THREAD_SIZE)>0);
    return (*nblock)*(*nthread);
}
#endif
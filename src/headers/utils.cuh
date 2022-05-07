#ifndef UTILS_H
#define UTILS_H
#include "config.h"
#include "stdlib.h"
#include <cstdio>
#include "utils.h"
#define TID (blockDim.x*blockIdx.x+threadIdx.x)

#define __all__ __device__ __host__
#define _single <<<1,1>>>
#define _kernel(nb,nt) <<<(nb),(nt)>>>

__host__ int thread_assign(int size,int* nblock,int*nthread){
    *nthread=min(size,THREAD_SIZE);
    *nblock=(size/THREAD_SIZE)+((size%THREAD_SIZE)>0);
    return (*nblock)*(*nthread);
}
#endif
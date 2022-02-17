#ifndef UTILS_H
#define UTILS_H
#include "config.cuh"
#define dimcf(st,i) (3*(i)+(st))
#define TID (blockDim.x*blockIdx.x+threadIdx.x)
#define max2(a,b) (((a)>(b))?(a):(b))
#define max3(a,b,c) max2((a),(max2((b),(c))))
#define __all__ __device__ __host__
__host__ int mapping_Char(char c);
__host__ bool load_file(int** px,int* xsize,const char* filename){
    FILE* file=fopen(filename,"r");
    if(file==NULL)return false;
    fseek(file,0,SEEK_END);
    *xsize=ftell(file);
    fseek(file,0,SEEK_SET);
    char* x=new char[*xsize+1];
    fgets(x,*xsize+1,file);
    fclose(file);
    int* x_int=new int[*xsize+1];
    x_int[0]=0;
    for(int i=0;i<*xsize;i++){
        x_int[i+1]=mapping_Char(x[i]);
    }
    cudaMalloc(px,sizeof(int)*(*xsize+1));
    cudaMemcpy(*px,x_int,sizeof(int)*(*xsize+1),cudaMemcpyHostToDevice);
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

template<typename T>
__host__ inline void cudaObjset(T* arr,T value,int count){
    int b,t;
    thread_assign(count,&b,&t);
    protected_space::_cudaObjset<<<b,t>>>(arr,value,count);
}

__host__ int mapping_Char(char c){
    for(int i=0;i<CHAR_NUMBER;i++){
        if(c==protected_space::Char_map[i])return i;
    }
    printf("Char not found!!\n");
    exit(0);
}
__host__ char to_Char(int i){
    return protected_space::Char_map[i];
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
#endif
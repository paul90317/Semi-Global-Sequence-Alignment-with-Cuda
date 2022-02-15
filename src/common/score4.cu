#ifndef SCORE_H
#define SCORE_H
#include "afg_unit.cu"
int DNA_map[]={'A','T','C','G','-'};
__host__ inline int mapping_DNA(char c){
    switch(c){
    case 'A':
        return 0;
    case 'T':
        return 1;
    case 'C':
        return 2;
    case 'G':
        return 3;
    default:
        printf("mapping_DNA: DNA not found\n");
        exit(0);
    }
}
static datatype score_matrix[4][4]={
    {1,-1,-1,-1},
    {-1,1,-1,-1},
    {-1,-1,1,-1},
    {-1,-1,-1,1},
};
static datatype* gscore_matrix;
static bool loaded=false;
__host__ void gscore_matrix_load(){
    if(!loaded){
        cudaMalloc(&gscore_matrix,16*sizeof(datatype));
        cudaMemcpy(gscore_matrix,score_matrix,16*sizeof(datatype),cudaMemcpyHostToDevice);//check this
        loaded=true;
    }
}
__device__ inline datatype gget_score(int i,int j){
    if(i==-1||j==-1)
        return -1;
    return gscore_matrix[4*i+j];
}

__host__ inline datatype cget_score(int i,int j){
    return score_matrix[i][j];
}
#endif
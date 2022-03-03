#ifndef UTILS_CPP_H
#define UTILS_CPP_H
#include "config.h"
#include "score.cuh"
#include <cstdlib>
#define max2(a,b) (((a)>(b))?(a):(b))
#define max3(a,b,c) max2((a),(max2((b),(c))))
typedef unsigned char byte;
typedef long long unsigned size_2D;
template<typename T>
T* oalloc(int count){
    return (T*)malloc(count*sizeof(T));
}
byte mapping_Char(char c){
    for(byte i=0;i<score::n_host;i++){
        if(c==score::Char_map[i])return i;
    }
    printf("Error: Char [%c] not found!!\n",c);
    exit(0);
}
inline char to_Char(byte i){
    return score::Char_map[i];
}
#endif
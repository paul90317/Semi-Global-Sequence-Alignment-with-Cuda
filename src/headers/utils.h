#ifndef UTILS_CPP_H
#define UTILS_CPP_H
#include "config.h"
#include <cstdlib>
#define max2(a,b) (((a)>(b))?(a):(b))
#define max3(a,b,c) max2((a),(max2((b),(c))))
typedef unsigned char byte;
typedef long long unsigned size_2D;
template<typename T>
T* oalloc(int count){
    return (T*)malloc(count*sizeof(T));
}

char my_get_ch(FILE* file){
    char c;
    while(true){
        c=getc(file);
        if(c==EOF)return c;
        if(c<32)continue;
        return c;
    }
}
#endif
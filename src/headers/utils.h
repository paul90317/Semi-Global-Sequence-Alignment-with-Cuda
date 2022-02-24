#ifndef UTILS_CPP_H
#define UTILS_CPP_H
#include "config.h"
#include <cstdlib>
#define max2(a,b) (((a)>(b))?(a):(b))
#define max3(a,b,c) max2((a),(max2((b),(c))))
typedef unsigned char byte;
template<typename T>
T* oalloc(int count){
    return (T*)malloc(count*sizeof(T));
}
byte mapping_Char(char c){
    for(byte i=0;i<CHAR_NUMBER;i++){
        if(c==protected_space::Char_map[i])return i;
    }
    printf("Char [%c] not found!!\n",c);
    exit(0);
}
inline char to_Char(byte i){
    return protected_space::Char_map[i];
}
#endif
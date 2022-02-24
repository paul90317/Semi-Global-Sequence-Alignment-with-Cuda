#ifndef MACRO_H
#define MACRO_H
#include "config.h"
#include "afg_unit.cuh"
#include "utils.cuh"

#define Y_NOT_END(idy,xsize,yr) (((idy)-(xsize)-1)<=(yr))
#define ZERO(l) ((l)-1)

namespace protected_space{
    __global__ void _afg_assign(afg_unit* g_au_arr,afg_unit value,int count){
        int tid=TID;
        if(tid<count)g_au_arr[tid]=value;
    }
}

inline void afg_assign(afg_unit* g_au_arr,afg_unit value,int count){
    int nb,nt;
    thread_assign(count,&nb,&nt);
    protected_space::_afg_assign _kernel(nb,nt)(g_au_arr,value,count);
}

inline void print_alm(FILE* file,char a,char b){
    static char buf[100];
    sprintf(buf,"%c %c\n",a,b);
    fputs(buf,file);
}

#endif
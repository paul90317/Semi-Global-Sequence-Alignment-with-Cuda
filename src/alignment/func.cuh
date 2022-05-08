#ifndef FUNC_H
#define FUNC_H

#include "comm.cuh"
#include "afg_unit.cuh"

#define Y_NOT_END(idy,xsize,yr) (((idy)-(xsize)-1)<=(yr))
#define ZERO(l) ((l)-1)

inline void print_alm(FILE* file,char a,char b){
    static char buf[100];
    sprintf(buf,"%c %c\n",a,b);
    fputs(buf,file);
}
template<typename T>
void assign_single(T* g_dst,T c_value){
    cudaMemcpy(g_dst,&c_value,sizeof(T),cudaMemcpyHostToDevice);
}
namespace protected_space{
    __global__ void _assign_afg(afg_unit* g_arr,afg_unit value,int count){
        int tid=TID;
        if(tid<count)g_arr[tid]=value;
    }
    __global__ void _assign_alm(alm_unit* garr,alm_unit value,int count){
        int tid=TID;
        if(tid>=count)return;
        garr[tid]=value;
    }
}

inline void assign_afg(afg_unit* g_arr,afg_unit value,int count=1){
    int nb,nt;
    thread_assign(count,&nb,&nt);
    protected_space::_assign_afg _kernel(nb,nt)(g_arr,value,count);
}

inline void assign_alm(alm_unit* garr,alm_unit value,int count=1){
    int nb,nt;
    thread_assign(count,&nb,&nt);
    protected_space::_assign_alm _kernel(nb,nt)(garr,value,count);
}

bool check_alm(char* filename,sequence x,sequence y,datatype* alm_score){
    char a,b;
    byte _x,_y;
    int xid=1,yid=1;
    FILE* file;
    file=fopen(filename,"r");
    int state=0;//m=0 x=1 y=2
    datatype score=0;
    int lineno=0;
    while(true){
        lineno++;
        a=my_get_ch(file);
        if(a==EOF)break;
        my_get_ch(file);//get space
        b=my_get_ch(file);
        _x=score::char2byte(a);
        _y=score::char2byte(b);
        if(_x==0){
            if(state!=1){
                score+=score::g_host;
                state=1;
            }else{
                score+=score::e_host;
            }
            if(_y!=y.cget(yid++)){
                return false;
            }
        }else if(_y==0){
            if(state!=2){
                score+=score::g_host;
                state=2;
            }else{
                score+=score::e_host;
            }
            if(_x!=x.cget(xid++)){
                return false;
            }
        }else{
            state=0;
            score+=score::score_matrix[_x*score::n_host+_y];
            if(_x!=x.cget(xid++)){
                printf("error mis match: [xid= %d, lineno= %d]\n",xid-1,lineno);
                return false;
            }
            if(_y!=y.cget(yid++)){
                printf("error mis match: [yid= %d, lineno= %d]\n",yid-1,lineno);
                return false;
            }
        }
    }
    *alm_score=score;
    return true;
}

#endif
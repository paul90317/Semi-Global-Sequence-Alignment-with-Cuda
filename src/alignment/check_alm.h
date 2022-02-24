#ifndef CHECK_ALM_H
#define CHECK_ALM_H
#include <cstdio>
#include "config.h"
#include "utils.h"

char my_get_ch(FILE* file){
    char c;
    while(true){
        c=getc(file);
        if(c==EOF)return c;
        if((c>'z'||c<'a')&&(c<'A'||c>'Z')&&(c<'0'||c>'9')&&c!='-')continue;
        return c;
    }
}

bool check_alm(byte* x,byte* y,datatype* alm_score){
    char a,b;
    byte _x,_y;
    int xid=1,yid=1;
    FILE* file;
    file=fopen(filename_alignment,"r");
    int state=0;//m=0 x=1 y=2
    datatype score=0;
    while(true){
        a=my_get_ch(file);
        if(a==EOF)break;
        b=my_get_ch(file);
        _x=mapping_Char(a);
        _y=mapping_Char(b);
        if(_x==0){
            if(state!=1){
                score+=SCORE_G;
                state=1;
            }else{
                score+=SCORE_E;
            }
            if(_y!=y[yid++]){
                return false;
            }
        }else if(_y==0){
            if(state!=2){
                score+=SCORE_G;
                state=2;
            }else{
                score+=SCORE_E;
            }
            if(_x!=x[xid++]){
                return false;
            }
        }else{
            state=0;
            score+=protected_space::score_matrix[_x][_y];
            if(_x!=x[xid++]){
                return false;
            }
            if(_y!=y[yid++]){
                return false;
            }
        }
    }
    *alm_score=score;
    return true;
}


#endif
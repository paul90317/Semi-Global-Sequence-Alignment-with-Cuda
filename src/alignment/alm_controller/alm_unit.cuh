#ifndef ALM_UNIT_H
#define ALM_UNIT_H
#include "config.h"
#include "utils.cuh"
#include <cstdio>
#include <iostream>

enum pointer:byte{
    tom,tox,toy,none    
};
class trace_unit{
public:
    pointer m,x,y;
    __all__ trace_unit(){}
    pointer next(pointer from){
        switch(from){
        case pointer::tom:return m;
        case pointer::tox:return x;
        case pointer::toy:return y;
        }
        return pointer::none;
    }
};
class alm_unit{
public:
    datatype m,x,y;
    alm_unit(){
        m=NEG_INF;
        x=NEG_INF;
        y=NEG_INF;
    }
    __device__ datatype to_m(int _x,int _y,pointer* from){
        datatype ret;
        if(m>x&&m>y){
            *from=pointer::tom;
            ret= m;
        }else if(x>y){
            *from=pointer::tox;
            ret= x;
        }else{
            *from=pointer::toy;
            ret=y;
        }
        return ret+protected_space::gscore_matrix[CHAR_NUMBER*_x+_y];
    }
    __all__ datatype to_x(pointer* from){
        datatype _m=m+SCORE_G;
        datatype _x=x+SCORE_E;
        datatype _y=y+SCORE_G;
        if(_m>_x&&_m>_y){
            *from=pointer::tom;
            return _m;
        }
        if(_x>_y){
            *from=pointer::tox;
            return _x;
        }
        *from=pointer::toy;
        return _y;
    }
    __all__ datatype to_y(pointer* from){
        datatype _m=m+SCORE_G;
        datatype _x=x+SCORE_G;
        datatype _y=y+SCORE_E;
        if(_m>_x&&_m>_y){
            *from=pointer::tom;
            return _m;
        }
        if(_x>_y){
            *from=pointer::tox;
            return _x;
        }
        *from=pointer::toy;
        return _y;
    }
    __all__ datatype result(){
        return max3(m,x,y);
    }
    __all__ datatype result(pointer* from){
        if(m>x&&m>y){
            *from=pointer::tom;
            return m;
        }
        if(x>y){
            *from=pointer::tox;
            return x;
        }
        *from=pointer::toy;
        return y;
    }
};

#endif
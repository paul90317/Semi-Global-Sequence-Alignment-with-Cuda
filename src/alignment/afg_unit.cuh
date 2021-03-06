//2D DP 陣列的單元

#ifndef AFG_UNIT_H
#define AFG_UNIT_H

#include "myconfig.h"
#include "comm.cuh"
#include "score.cuh"

class res_unit{
public:
    datatype score;
    int xmid;
    bool is_xbackgap;
    __all__ res_unit(datatype _score, int _xmid,bool _is_xbackgap){
        score=_score;
        xmid=_xmid;
        is_xbackgap=_is_xbackgap;
    }
    __all__ res_unit(){
        score=NEG_INF;
    }
    __all__ bool operator>(res_unit& b){
        return score>b.score;
    }
    __all__ bool operator>=(res_unit& b){
        return score>=b.score;
    }
    __all__ void operator=(datatype s){
        score=s;
    }
    __all__ res_unit operator+(datatype s){
        res_unit u(score,xmid,is_xbackgap);
        u.score+=s;
        return u;
    }
    __all__ bool operator<=(datatype x){
        return score<=x;
    }
};

class afg_unit{
public:
    res_unit m,x,y;
    
    __device__ res_unit to_m(byte _x,byte _y){
        return max3(m,x,y)+score::match(_x,_y);
    }
    __device__ res_unit to_x(){// y have gap, mean x move
        res_unit a=m+score::g_device;
        res_unit b=x+score::e_device;
        res_unit c=y+score::g_device;
        return max3(a,b,c);
    }
    __all__ res_unit to_y(){// x have gap, mean y move
        res_unit a=m+score::g_device;
        res_unit b=x+score::g_device;
        res_unit c=y+score::e_device;
        return max3(a,b,c);
    }

    __all__ res_unit& result(){
        return max3(m,x,y);
    }

};

#endif
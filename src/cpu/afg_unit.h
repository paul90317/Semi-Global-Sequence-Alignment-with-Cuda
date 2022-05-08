//2D DP 陣列的單元

#ifndef AFG_UNIT_H
#define AFG_UNIT_H

#include "config.h"
#include "comm.cuh"

class afg_unit{
public:
    datatype m,x,y;
    afg_unit(){
        m=NEG_INF;
        x=NEG_INF;
        y=NEG_INF;
    }
    datatype to_m(int i,int j){
        return max3(m,x,y)+score::match(i,j);
    }
    datatype to_x(){// y have gap, mean x move
        return max3(m+score::g_host,x+score::e_host,y+score::g_host);
    }
    datatype to_y(){// x have gap, mean y move
        return max3(m+score::g_host,x+score::g_host,y+score::e_host);
    }

    datatype result(){
        return max3(m,x,y);
    }
};

#endif
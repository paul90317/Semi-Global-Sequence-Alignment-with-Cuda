//2D DP 陣列的單元

#ifndef AFG_UNIT_H
#define AFG_UNIT_H

#include "utils.h"
#include "config.h"

class afg_unit{
public:
    datatype m,x,y;
    afg_unit(){
        m=NEG_INF;
        x=NEG_INF;
        y=NEG_INF;
    }
    datatype to_m(int i,int j){
        return max3(m,x,y)+protected_space::score_matrix[i][j];
    }
    datatype to_x(){// y have gap, mean x move
        return max3(m+SCORE_G,x+SCORE_E,y+SCORE_G);
    }
    datatype to_y(){// x have gap, mean y move
        return max3(m+SCORE_G,x+SCORE_G,y+SCORE_E);
    }

    datatype result(){
        return max3(m,x,y);
    }
};

#endif
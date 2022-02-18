//2D DP 陣列的單元

#ifndef AFG_UNIT_H
#define AFG_UNIT_H

#include "utils.cuh"

class res_unit{
public:
    datatype score;
    int ystart,yend;
    int xstart,xend;
    bool is_backgap;
    __all__ res_unit(datatype _score, int _xstart,int _xend,int _ystart,int _yend){
        score=_score;
        xstart=_xstart;
        xend=_xend;
        ystart=_ystart;
        yend=_yend;
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
        res_unit u(score,xstart,xend,ystart,yend);
        u.score+=s;
        return u;
    }
    __all__ bool operator<=(datatype x){
        return score<=x;
    }
};

//get score in gpu
__device__ datatype gget_score(int i,int j){
    return protected_space::gscore_matrix[CHAR_NUMBER*i+j];
}

class afg_unit{
public:
    res_unit m,x,y;
    
    __device__ res_unit to_m(int i,int j){
        return max3(m,x,y)+gget_score(i,j);
    }
    __all__ res_unit to_x(){// y have gap, mean x move
        return max3(m+SCORE_G,x+SCORE_E,y+SCORE_G);
    }
    __all__ res_unit to_y(){// x have gap, mean y move
        return max3(m+SCORE_G,x+SCORE_G,y+SCORE_E);
    }

    __all__ res_unit& result(){
        return max3(m,x,y);
    }

};

//dimension move
namespace protected_space
{
    __global__ void _dim_move(afg_unit* M,int count3){
        int tid=TID;
        if(tid>=count3)return;
        M[dimcf(2,tid)]=M[dimcf(1,tid)];
        M[dimcf(1,tid)]=M[dimcf(0,tid)];
    }
} // namespace protected_space


__host__ void dim_move(afg_unit* M,int count3){
    int b,t;
    thread_assign(count3,&b,&t);
    protected_space::_dim_move<<<b,t>>>(M,count3);
}

#endif
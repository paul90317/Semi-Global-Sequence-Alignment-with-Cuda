//2D DP 陣列的單元
#ifndef AFG_UNIT_H
#define AFG_UNIT_H

class res_unit{
public:
    datatype score;
#if Y_FREE_START
    int ystart;
#endif
#if X_FREE_START
    int xstart;
#endif
    __all__ res_unit(){
        score=NEG_INF;
    }
#if X_FREE_START&&X_FREE_END&&Y_FREE_START&&Y_FREE_END
    __all__ res_unit(datatype _score,int _xstart,int _xend,int _ystart,int _yend){
        score=_score;
        xstart=_xstart;
        ystart=_ystart;
    }
#endif
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
        res_unit u=*this;
        u.score=score+s;
        return u;
    }
    __all__ bool operator<=(datatype x){
        return score<=x;
    }
};

class res_unit_end:res_unit{
public:
    int xend;
    int yend;
}

class afg_unit{
public:
    res_unit m,x,y;
    
    __device__ res_unit to_m(int i,int j){
        return max3(m,x,y)+protected_space::gscore_matrix[CHAR_NUMBER*i+j];
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

#endif
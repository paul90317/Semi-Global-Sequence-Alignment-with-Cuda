#ifndef AFG_UNIT_GPU_H
#define AFG_UNIT_GPU_H

#define max2(a,b) ((a>b)?a:b)
#define max3(a,b,c) max2(a,max2(b,c))
#define max3sel(a,b,c,ao,bo,co) ((((a)>(b))&&((a)>(c)))?(ao):(((b)>(c))?(bo):(co)))
#define max2sel(a,b,ao,bo) (((a)>(b))?(ao):(bo))
#define NEG_INF -10000000

#define SCORE_G -2
#define SCORE_E -1
#define SCORE_HIT 1
#define SCORE_MIS -1

class res_unit{
public:
    int score,start;
    bool is_backgap;
    __device__ res_unit(int _score,int _start,bool _is_backgap){
        score=_score;
        start=_start;
        is_backgap=_is_backgap;
    }
    __host__ res_unit(){

    }
    __device__ bool operator>(res_unit& b){
        return score>b.score;
    }
    
    __device__ void operator=(int s){
        score=s;
    }
    __device__ res_unit operator+(int s){
        res_unit u(score,start,is_backgap);
        u.score+=s;
        return u;
    }
};


class afg_unit{
public:
    res_unit m,x,y;
    __device__ res_unit gto_m(bool equ){
        return max3(m,x,y)+(equ?SCORE_HIT:SCORE_MIS);
    }
    __device__ res_unit gto_x(){// y have gap, mean x move
        return max3(m+SCORE_G,x+SCORE_E,y+SCORE_G);
    }
    __device__ res_unit gto_y(){// x have gap, mean y move
        return max3(m+SCORE_G,x+SCORE_G,y+SCORE_E);
    }

    __host__ res_unit cresult(){
        return max3sel(m.score,x.score,y.score,m,x,y);
    }
    __device__ res_unit gresult(){
        return max3(m,x,y);
    }
private:
    
};

#endif
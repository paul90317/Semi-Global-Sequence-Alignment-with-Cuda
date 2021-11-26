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

class afg_unit{
public:
    int m,x,y;
    int mstart,xstart,ystart;
    __device__ int gto_m(bool equ){
        return max3(m,x,y)+(equ?SCORE_HIT:SCORE_MIS);
    }
    __device__ int gto_x(){// y have gap, mean x move
        return max3(m+SCORE_G,x+SCORE_E,y+SCORE_G);
    }
    __device__ int gto_y(){// x have gap, mean y move
        return max3(m+SCORE_G,x+SCORE_G,y+SCORE_E);
    }

    __device__ int start_m(){
        return max3sel(m,x,y,mstart,xstart,ystart);
    }
    __device__ int start_x(){// y have gap, mean x move
        return max3sel(m+SCORE_G,x+SCORE_E,y+SCORE_G,mstart,xstart,ystart);
    }
    __device__ int start_y(){// x have gap, mean y move
        return max3sel(m+SCORE_G,x+SCORE_G,y+SCORE_E,mstart,xstart,ystart);
    }

    __host__ int cstart_m(){
        return max3sel(m,x,y,mstart,xstart,ystart);
    }
    __host__ int cresult(){
        return max3(m,x,y);
    }
    __device__ int gresult(){
        return max3(m,x,y);
    }
private:
    
};

#endif
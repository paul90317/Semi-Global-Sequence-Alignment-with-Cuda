#include "alm_node.h"

#define max2(a,b) ((a>b)?a:b)
#define max3(a,b,c) max2(a,max2(b,c))
#define max3sel(a,b,c,ao,bo,co) ((((a)>(b))&&((a)>(c)))?(ao):(((b)>(c))?(bo):(co)))
#define max2sel(a,b,ao,bo) (((a)>(b))?(ao):(bo))
#define NEG_INF -10000000

#define SCORE_G -2
#define SCORE_E -1
#define SCORE_HIT 1
#define SCORE_MIS -1

__device__ alm_node* alm_node_set(alm_node* ret,char _x,char _y,alm_node* _next){
    ret->x=_x;
    ret->y=_y;
    ret->next=_next;
    return ret;
}

class afg_unit{
public:
    int m,x,y;
    struct alm_node *stk_m,*stk_x,*stk_y;
    __host__ afg_unit(){
        m=x=y=NEG_INF;// -inf
        stk_m=nullptr;
        stk_x=nullptr;
        stk_y=nullptr;
    }
    __device__ ~afg_unit(){

    }
    int to_m(bool equ){
        return max3(m,x,y)+(equ?SCORE_HIT:SCORE_MIS);
    }
    int to_x(){// y have gap, mean x move
        return max3(m+SCORE_G,x+SCORE_E,y+SCORE_G);
    }
    int to_y(){// x have gap, mean y move
        return max3(m+SCORE_G,x+SCORE_G,y+SCORE_E);
    }
    int result(){
        return max3(m,x,y);
    }
    static int equal(bool equ){
        return equ?SCORE_HIT:SCORE_MIS;
    }

    __device__ int gresult(){
        return max3(m,x,y);
    }

    __device__ int gto_m(bool equ){
        return max3(m,x,y)+(equ?SCORE_HIT:SCORE_MIS);
    }
    __device__ int gto_x(){// y have gap, mean x move
        return max3(m+SCORE_G,x+SCORE_E,y+SCORE_G);
    }
    __device__ int gto_y(){// x have gap, mean y move
        return max3(m+SCORE_G,x+SCORE_G,y+SCORE_E);
    }

    __device__ alm_node* alm_m(char _x,char _y,alm_node* ret){
        return (ret)?alm_node_set(ret,_x,_y,max3sel(m,x,y,stk_m,stk_x,stk_y)):nullptr;
    }
    __device__ alm_node* alm_x(char _x,alm_node* ret){
        return (ret)?alm_node_set(ret,_x,'-',max3sel(m+SCORE_G,x+SCORE_E,y+SCORE_G,stk_m,stk_x,stk_y)):nullptr;
    }
    __device__ alm_node* alm_y(char _y,alm_node* ret){
        return (ret)?alm_node_set(ret,'-',_y,max3sel(m+SCORE_G,x+SCORE_G,y+SCORE_E,stk_m,stk_x,stk_y)):nullptr;
    }

    __device__ alm_node* best_alm(){
        return max3sel(m,x,y,stk_m,stk_x,stk_y);
    }
    alm_node* cbest_alm(){
        return max3sel(m,x,y,stk_m,stk_x,stk_y);
    }
private:
    
};
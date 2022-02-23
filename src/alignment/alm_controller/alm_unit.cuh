#ifndef ALM_UNIT_H
#define ALM_UNIT_H
#include "config.h"
#include "utils.cuh"
#include "alm_controller/mem_controller.cuh"
#include <cstdio>
#include <iostream>

class alm_node{
public:
    byte x, y;
    alm_node *next=NULL;
    __device__ static alm_node* new_node(int tid,byte _x,byte _y,alm_node *_next){
        alm_node* tmp=(alm_node*)mem_controller::new_node(tid,sizeof(alm_node));
        tmp->x=_x;
        tmp->y=_y;
        tmp->next=_next;
        return tmp;
    }
};


class alm_head{
public:
    datatype score=NEG_INF;
    alm_node *first=NULL;
    __all__ alm_head(){
        score=NEG_INF;
        first=NULL;
    }
    __device__ alm_head add(int tid,byte _x,byte _y){
        alm_head u;
        u.score=score+protected_space::gscore_matrix[_x*CHAR_NUMBER+_y];
        u.first=alm_node::new_node(tid,_x,_y,first);
        return u;
    }
    __device__ alm_head add(int tid,byte _x,byte _y,datatype _score){
        alm_head u;
        u.score=score+_score;
        u.first=alm_node::new_node(tid,_x,_y,first);
        return u;
    }
    __host__ void output(FILE*file){
        alm_head ah;
        alm_node an,*t;
        while(first){
            cudaMemcpy(&an,first,sizeof(alm_node),cudaMemcpyDeviceToHost);
            t=(alm_node*)malloc(sizeof(alm_node));
            t->next=ah.first;
            t->x=an.x;
            t->y=an.y;
            ah.first=t;
            first=an.next;
        }
        while(ah.first){
            print_alm(file,to_Char(ah.first->x),to_Char(ah.first->y));
            t=ah.first;
            ah.first=ah.first->next;
            free(t);
        }
    }
};

class alm_unit{
public:
    alm_head m,x,y;
    __device__ alm_head to_m(int tid,int _x,int _y){
        if(m.score>x.score&&m.score>y.score){
            return m.add(tid,_x,_y);
        }
        if(x.score>y.score){
            return x.add(tid,_x,_y);
        }
        return y.add(tid,_x,_y);
    }
    __device__ alm_head to_x(int tid,int _x){
        datatype ms=m.score+SCORE_G;
        datatype xs=x.score+SCORE_E;
        datatype ys=y.score+SCORE_G;
        if(ms>xs&&ms>ys){
            return m.add(tid,_x,0,SCORE_G);
        }
        if(xs>ys){
            return x.add(tid,_x,0,SCORE_E);
        }
        return y.add(tid,_x,0,SCORE_G);
    }
    __device__ alm_head to_y(int tid,int _y){
        datatype ms=m.score+SCORE_G;
        datatype xs=x.score+SCORE_G;
        datatype ys=y.score+SCORE_E;
        if(ms>xs&&ms>ys){
            return m.add(tid,0,_y,SCORE_G);
        }
        if(xs>ys){
            return x.add(tid,0,_y,SCORE_G);
        }
        return y.add(tid,0,_y,SCORE_E);
    }
    __all__ alm_head result(){
        if(m.score>x.score&&m.score>y.score){
            return m;
        }
        if(x.score>y.score){
            return x;
        }
        return y;
    }
};

#endif
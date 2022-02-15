#ifndef AFG_CONTROLLER_H
#define AFG_CONTROLLER_H

#include "afg_unit.cu"
#include "utils.cu"
#define THREAD_SIZE 1024

class afg_controller{
private:
    
public:
    afg_unit** GM;
    int xsize,ysize;
    int xcalculate_sz;
    char *gx,*gy;
    afg_controller(char* _x,char* _y,int _xsize,int _ysize,int free_start){
        xsize=_xsize;
        ysize=_ysize;
        gmalloc(&gx,xsize+1);
        gmemcpy_h2d(gx+1,_x,_xsize);
        gmalloc(&gy,ysize+1);
        gmemcpy_h2d(gy+1,_y,ysize);
        afg_unit* tmp;
        gmalloc(&tmp,(xsize+2)*3);
        gmalloc(&GM,xsize+2);
        for(int i=0;i<xsize+2;i++){
            gassign(GM+i,tmp+i);
        }
        for(int i=0;i<(xsize+2)*3;i++){
            afg_unit t;
            if(i>=3&&i<6){
                t.m=0;
            }else{
                t.m=NEG_INF;
            }
            gassign(&tmp[i],t);
        }
        
    }
};


#endif
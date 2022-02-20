#ifndef AFG_CONTROLER_H
#define AFG_CONTROLER_H

#include "afg_unit.cuh"
#include "config.h"
#include "utils.cuh"
#include "macro.cuh"

__global__ void calculate(afg_unit*GM,int* gx,int* gy,int xl,int xr,int yl,int yr,int ymover,int ymid) {
    int tid=TID;
    int xid=tid+ZERO(xl);
    int yid=ymover-tid-1;
    if((xid<ZERO(xl))||(yid<ZERO(yl))||(xid>xr)||(yid>yr))return;
    GM[dimcf(0,xid)].x=GM[dimcf(1,xid-1)].to_x();
    GM[dimcf(0,xid)].y=GM[dimcf(1,xid)].to_y();
    GM[dimcf(0,xid)].m=GM[dimcf(2,xid-1)].to_m(gx[xid],gy[yid]);
    if(yid==ymid){
        GM[dimcf(0,xid)].m.xmid=xid;
        GM[dimcf(0,xid)].m.is_xbackgap=false;
        GM[dimcf(0,xid)].y.xmid=xid;
        GM[dimcf(0,xid)].y.is_xbackgap=true;
    }    
    
}

class afg_controller{
private:
    afg_unit *GM;
    int *gx,*gy;
    __host__ void initM(int l,int r,bool xgap){
        int initx=ZERO(l)-1;
        int cnt=r-l+3;
        afg_unit au;
        afg_assign(GM+initx*3,au,cnt*3);
        if(xgap){
            au.y=0;
        }else{
            au.m=0;
        }
        afg_assign(GM+dimcf(1,ZERO(l)),au,1);
    }
    __host__ void dp(int xl,int xr,int yl,int yr,int ymid,bool xgap){
        initM(xl,xr,xgap);
        int xsize=xr-xl+1;
        int nb,nt;
        thread_assign(xsize+1,&nb,&nt);
        for(int ymover=ZERO(yl)+2;Y_NOT_END(ymover,xsize,yr);ymover++){
            calculate _kernel(nb,nt)(GM,gx,gy,xl,xr,yl,yr,ymover,ymid);
            dim_move(GM+3*ZERO(xl),xsize+1);
        }
    }
public:
    __host__ afg_controller(){};
    __host__ afg_controller(int*_gx,int*_gy,int _xsize){
        cudaMalloc(&GM, (_xsize+2)*3*sizeof(afg_unit));
        GM+=3;
        gx=_gx;
        gy=_gy;
    }
    __host__ res_unit get_xmid(int xl,int xr,int yl,int yr,int ymid,bool xgap){
        dp(xl,xr,yl,yr,ymid,xgap);
        afg_unit a;
        cudaMemcpy(&a, GM+dimcf(0,xr), sizeof(afg_unit),cudaMemcpyDeviceToHost);
        return a.result();
    }
};


#endif
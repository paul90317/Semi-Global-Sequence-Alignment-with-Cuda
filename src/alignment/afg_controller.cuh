#ifndef AFG_CONTROLER_H
#define AFG_CONTROLER_H

#include "afg_unit.cuh"
#include "config.h"
#include "utils.cuh"
#include "macro.cuh"

__global__ static void calculate(afg_unit*GM,afg_unit*GM1,afg_unit*GM2,byte* gx,byte* gy,int xl,int xr,int yl,int yr,int ymover,int ymid) {
    int tid=TID;
    int xid=tid+ZERO(xl);
    int yid=ymover-tid-1;
    if((xid<ZERO(xl))||(yid<ZERO(yl))||(xid>xr)||(yid>yr))return;
    GM[xid].x=GM1[xid-1].to_x();
    GM[xid].y=GM1[xid].to_y();
    GM[xid].m=GM2[xid-1].to_m(gx[xid],gy[yid]);
    if(yid==ymid){
        GM[xid].m.xmid=xid;
        GM[xid].m.is_xbackgap=false;
        GM[xid].y.xmid=xid;
        GM[xid].y.is_xbackgap=true;
    }    
    
}

class afg_controller{
private:
    afg_unit *GM,*GM1,*GM2;
    byte *gx,*gy;
    __host__ void initM(int l,int r,bool xgap){
        int initx=ZERO(l)-1;
        int cnt=r-l+3;
        afg_unit au;
        afg_assign(GM+initx,au,cnt);
        afg_assign(GM1+initx,au,cnt);
        afg_assign(GM2+initx,au,cnt);
        if(xgap){
            au.y=0;
        }else{
            au.m=0;
        }
        afg_assign(GM1+ZERO(l),au,1);
    }
    __host__ void dp(int xl,int xr,int yl,int yr,int ymid,bool xgap){
        initM(xl,xr,xgap);
        int xsize=xr-xl+1;
        int nb,nt;
        thread_assign(xsize+1,&nb,&nt);
        for(int ymover=ZERO(yl)+2;Y_NOT_END(ymover,xsize,yr);ymover++){
            calculate _kernel(nb,nt)(GM,GM1,GM2,gx,gy,xl,xr,yl,yr,ymover,ymid);
            cudaMemcpy(GM2+ZERO(xl),GM1+ZERO(xl),sizeof(afg_unit)*(xsize+1),cudaMemcpyDeviceToDevice);
            cudaMemcpy(GM1+ZERO(xl),GM+ZERO(xl),sizeof(afg_unit)*(xsize+1),cudaMemcpyDeviceToDevice);
        }
    }
public:
    __host__ afg_controller(){};
    __host__ afg_controller(byte*_gx,byte*_gy,int _xsize){
        cudaMalloc(&GM, (_xsize+2)*sizeof(afg_unit));
        cudaMalloc(&GM1, (_xsize+2)*sizeof(afg_unit));
        cudaMalloc(&GM2, (_xsize+2)*sizeof(afg_unit));
        GM++;
        GM1++;
        GM2++;
        gx=_gx;
        gy=_gy;
    }
    __host__ res_unit get_xmid(int xl,int xr,int yl,int yr,int ymid,bool xgap){
        dp(xl,xr,yl,yr,ymid,xgap);
        afg_unit a;
        cudaMemcpy(&a, GM+xr, sizeof(afg_unit),cudaMemcpyDeviceToHost);
        return a.result();
    }
};


#endif
#ifndef ALM_CONTROLLER_H
#define ALM_CONTROLLER_H

#include "alm_unit.cuh"
#include "config.h"
#include "utils.cuh"
#include "macro.cuh"

namespace protected_space{
    __global__ static void _alm_assign(alm_unit* g_au_arr,alm_unit value,int count){
        int tid=TID;
        if(tid>=count)return;
        g_au_arr[tid]=value;
    }
}

static inline void alm_assign(alm_unit* g_au_arr,alm_unit value,int count){
    int nb,nt;
    thread_assign(count,&nb,&nt);
    protected_space::_alm_assign _kernel(nb,nt)(g_au_arr,value,count);
}

__global__ static void calculate(alm_unit*GM,alm_unit*GM1,alm_unit*GM2,int* gx,int* gy,int xl,int xr,int yl,int yr,int ymover) {
    int tid=TID;
    int xid=tid+ZERO(xl);
    int yid=ymover-tid-1;
    if((xid<ZERO(xl))||(yid<ZERO(yl))||(xid>xr)||(yid>yr))return;
    int _x=gx[xid];
    int _y=gy[yid];
    GM[tid].x=GM1[tid-1].to_x(tid,_x);
    GM[tid].y=GM1[tid].to_y(tid,_y);
    GM[tid].m=GM2[tid-1].to_m(tid,_x,_y);
}

class alm_controller{
private:
    alm_unit *GM,*GM1,*GM2;
    int *gx,*gy;
    __host__ void initM(int l,int r,bool xbackgap){
        int cnt=r-l+3;
        alm_unit au;
        alm_assign(GM-1,au,cnt);
        alm_assign(GM1-1,au,cnt);
        alm_assign(GM2-1,au,cnt);
        if(xbackgap){
            au.y.score=0;
        }else{
            au.m.score=0;
        }
        alm_assign(GM1,au,1);
    }
    __host__ void dp(int xl,int xr,int yl,int yr,bool xbackgap){
        mem_controller::clear();
        initM(xl,xr,xbackgap);
        int xsize=xr-xl+1;
        int nb,nt;
        thread_assign(xsize+1,&nb,&nt);
        for(int ymover=ZERO(yl)+2;Y_NOT_END(ymover,xsize,yr);ymover++){
            calculate _kernel(nb,nt)(GM,GM1,GM2,gx,gy,xl,xr,yl,yr,ymover);
            cudaMemcpy(GM2,GM1,sizeof(alm_unit)*(xsize+1),cudaMemcpyDeviceToDevice);
            cudaMemcpy(GM1,GM,sizeof(alm_unit)*(xsize+1),cudaMemcpyDeviceToDevice);
        }
    }
public:
    __host__ alm_controller(){};
    __host__ alm_controller(int*_gx,int*_gy){
        cudaMalloc(&GM, (ALM_END_POINT_SIZE+1)*sizeof(alm_unit));
        cudaMalloc(&GM1, (ALM_END_POINT_SIZE+1)*sizeof(alm_unit));
        cudaMalloc(&GM2, (ALM_END_POINT_SIZE+1)*sizeof(alm_unit));
        GM++;
        GM1++;
        GM2++;
        gx=_gx;
        gy=_gy;
    }
    __host__ alm_head get_alm(int xl,int xr,int yl,int yr,bool xbackgap){
        dp(xl,xr,yl,yr,xbackgap);
        alm_unit a;
        cudaMemcpy(&a, GM+xr-xl+1, sizeof(alm_unit),cudaMemcpyDeviceToHost);
        return a.result();
    }
};


#endif